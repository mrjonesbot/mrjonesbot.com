class GenerateChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id, user_message)
    chat = Chat.find(chat_id)

    begin
      # Check if API key is configured
      unless ENV["ANTHROPIC_API_KEY"] || Rails.application.credentials.dig(:anthropic, :api_key)
        raise "ANTHROPIC_API_KEY is not configured. Please set it in ENV or Rails credentials."
      end

      # Ask the chat with the user message
      # The chat will automatically use the system_message method if it's the first message
      response = chat.ask(user_message)

      # Broadcast the response via Turbo Stream
      # Reload chat to get updated messages
      chat.reload

      # Remove the "AI is thinking..." indicator
      Turbo::StreamsChannel.broadcast_remove_to(
        "chat_#{chat_id}",
        target: "ai_thinking"
      )

      # Append the AI response
      Turbo::StreamsChannel.broadcast_append_to(
        "chat_#{chat_id}",
        target: "messages",
        partial: "chats/message",
        locals: { role: "assistant", content: chat.messages.last.content }
      )
    rescue => e
      Rails.logger.error "Error generating chat response: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Remove the "AI is thinking..." indicator
      Turbo::StreamsChannel.broadcast_remove_to(
        "chat_#{chat_id}",
        target: "ai_thinking"
      )

      # Broadcast error message
      error_message = if e.message.include?("ANTHROPIC_API_KEY")
        "⚠️ API key not configured. Please set ANTHROPIC_API_KEY environment variable."
      else
        "Sorry, I encountered an error. Please try again."
      end

      Turbo::StreamsChannel.broadcast_append_to(
        "chat_#{chat_id}",
        target: "messages",
        partial: "chats/message",
        locals: { role: "assistant", content: error_message }
      )
    end
  end
end
