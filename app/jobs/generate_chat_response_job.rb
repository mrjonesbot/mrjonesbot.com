class GenerateChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id, user_message)
    chat_record = Chat.find(chat_id)

    begin
      # Save user message
      chat_record.messages.create!(role: "user", content: user_message)

      # Build RubyLLM chat with system prompt
      llm_chat = RubyLLM.chat(model: "claude-haiku-4-5-20251001")
      llm_chat.with_instructions(chat_record.system_prompt)

      # Replay prior messages for conversation context (excluding the latest user message)
      prior_messages = chat_record.messages.order(:created_at).to_a
      prior_messages[0..-2].each do |msg|
        llm_chat.add_message(role: msg.role.to_sym, content: msg.content)
      end

      # Phase 1: Replace "AI is thinking..." with empty streaming bubble
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{chat_id}",
        target: "ai_thinking",
        html: streaming_bubble_html("")
      )

      # Phase 2: Stream with throttled broadcasts
      accumulated = ""
      last_broadcast = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      response = llm_chat.ask(user_message) do |chunk|
        next unless chunk.content.present?

        accumulated << chunk.content

        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        if (now - last_broadcast) >= 0.08
          broadcast_streaming_update(chat_id, accumulated)
          last_broadcast = now
        end
      end

      # Final streaming update to ensure all content is shown
      broadcast_streaming_update(chat_id, accumulated)

      # Save assistant message
      chat_record.messages.create!(role: "assistant", content: response.content)

      # Phase 3: Replace streaming bubble with markdown-rendered message
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{chat_id}",
        target: "streaming_message",
        partial: "chats/message",
        locals: { role: "assistant", content: response.content }
      )
    rescue => e
      Rails.logger.error "Error generating chat response: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Remove whichever indicator exists (one or the other will be present)
      Turbo::StreamsChannel.broadcast_remove_to(
        "chat_#{chat_id}",
        target: "streaming_message"
      )
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

  private

  def streaming_bubble_html(text)
    escaped = ERB::Util.html_escape(text)
    <<~HTML
      <div id="streaming_message" style="display: flex; justify-content: flex-start; margin-bottom: var(--space-6);">
        <div class="card--subtle" style="padding: var(--space-4); border-radius: var(--radius-md); max-width: 80%;">
          <p class="text-caption" style="margin-bottom: var(--space-2); text-transform: uppercase; font-weight: var(--weight-semibold); letter-spacing: 0.05em;">AI</p>
          <div id="streaming_content" class="text-body markdown-content">#{escaped}</div>
        </div>
      </div>
    HTML
  end

  def broadcast_streaming_update(chat_id, text)
    escaped = ERB::Util.html_escape(text).to_s.gsub("\n", "<br>")
    Turbo::StreamsChannel.broadcast_update_to(
      "chat_#{chat_id}",
      target: "streaming_content",
      html: escaped
    )
  end
end
