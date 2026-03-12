class ChatsController < ApplicationController
  skip_before_action :protect_from_spam, raise: false
  before_action :check_rate_limit, only: [:ask]

  def new
    # Renders the chat overlay via Turbo Frame
  end

  def create
    @chat = Chat.create!(session_token: ensure_session_token)
    session[:chat_id] = @chat.id

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "messages",
          partial: "chats/messages",
          locals: { chat: @chat }
        )
      end
    end
  end

  def ask
    @chat = find_or_create_chat
    user_message = params[:message]

    # Add user message to the conversation
    respond_to do |format|
      format.turbo_stream do
        streams = []

        # Always attempt to hide empty state and suggested questions
        streams << turbo_stream.remove("chat_empty_state")
        streams << turbo_stream.remove("suggested_questions")

        # Append user message
        streams << turbo_stream.append(
          "messages",
          partial: "chats/message",
          locals: { role: "user", content: user_message }
        )

        # Show AI thinking indicator
        streams << turbo_stream.append(
          "messages",
          "<div id='ai_thinking' class='text-gray-400 text-sm'>AI is thinking...</div>"
        )

        render turbo_stream: streams
      end
    end

    # Generate AI response in the background
    GenerateChatResponseJob.perform_later(@chat.id, user_message)
  end

  def export
    @chat = Chat.find(params[:id])

    respond_to do |format|
      format.txt do
        render plain: generate_chat_export(@chat), content_type: 'text/plain'
      end
    end
  end

  private

  def find_or_create_chat
    # First try to find by session chat_id
    chat_id = params[:id] == "new" ? session[:chat_id] : params[:id]

    if chat_id
      chat = Chat.find_by(id: chat_id)
      return chat if chat
    end

    # If no chat found, try to find by session token
    session_token = ensure_session_token
    chat = Chat.find_by(session_token: session_token)

    if chat
      session[:chat_id] = chat.id
      return chat
    end

    # Create new chat with session token
    Chat.create!(session_token: session_token).tap do |c|
      session[:chat_id] = c.id
    end
  end

  def ensure_session_token
    session[:chat_session_token] ||= SecureRandom.hex(32)
  end

  def generate_chat_export(chat)
    output = "Chat Export - #{chat.created_at.strftime('%Y-%m-%d %H:%M:%S')}\n"
    output += "=" * 80 + "\n\n"

    chat.messages.order(:created_at).each do |message|
      role_label = message.role == "user" ? "YOU" : "AI"
      output += "#{role_label}:\n"
      output += message.content.to_s + "\n"
      output += "-" * 80 + "\n\n"
    end

    output
  end

  def check_rate_limit
    # Rate limit: 10 messages per minute per IP
    cache_key = "chat_rate_limit:#{request.remote_ip}"
    count = Rails.cache.read(cache_key) || 0

    if count >= 10
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "messages",
            "<div class='text-red-500 text-sm' style='color: var(--text-error); padding: var(--space-4); background: rgba(239, 68, 68, 0.1); border-radius: var(--radius-md);'>⚠️ Rate limit exceeded. Please wait a minute before sending more messages.</div>"
          ), status: :too_many_requests
        end
      end
      return
    end

    # Increment counter with 1 minute expiry
    Rails.cache.write(cache_key, count + 1, expires_in: 1.minute)
  end
end
