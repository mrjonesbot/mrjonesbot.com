class GenerateChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id, user_message)
    chat_record = Chat.find(chat_id)

    begin
      # Save user message
      chat_record.messages.create!(role: "user", content: user_message)

      # Build RubyLLM chat with system prompt
      llm_chat = RubyLLM.chat
      llm_chat.with_instructions(chat_record.system_prompt)

      # Replay prior messages for conversation context (excluding the latest user message)
      prior_messages = chat_record.messages.order(:created_at).to_a
      prior_messages[0..-2].each do |msg|
        llm_chat.add_message(role: msg.role.to_sym, content: msg.content)
      end

      # Ask with the latest user message (this triggers the API call)
      response = llm_chat.ask(user_message)

      # Save assistant message
      chat_record.messages.create!(role: "assistant", content: response.content)

      Turbo::StreamsChannel.broadcast_remove_to(
        "chat_#{chat_id}",
        target: "ai_thinking"
      )

      Turbo::StreamsChannel.broadcast_append_to(
        "chat_#{chat_id}",
        target: "messages",
        partial: "chats/message",
        locals: { role: "assistant", content: response.content }
      )
    rescue => e
      Rails.logger.error "Error generating chat response: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      Turbo::StreamsChannel.broadcast_remove_to(
        "chat_#{chat_id}",
        target: "ai_thinking"
      )

      Turbo::StreamsChannel.broadcast_append_to(
        "chat_#{chat_id}",
        target: "messages",
        partial: "chats/message",
        locals: { role: "assistant", content: "Sorry, I encountered an error. Please try again." }
      )
    end
  end
end
