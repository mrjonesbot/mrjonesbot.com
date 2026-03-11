class ChatsController < ApplicationController
  skip_before_action :protect_from_spam, raise: false

  def create
    @chat = Chat.create!
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
        render turbo_stream: [
          turbo_stream.append(
            "messages",
            partial: "chats/message",
            locals: { role: "user", content: user_message }
          ),
          turbo_stream.append(
            "messages",
            "<div id='ai_thinking' class='text-gray-400 text-sm'>AI is thinking...</div>"
          )
        ]
      end
    end

    # Generate AI response in the background
    GenerateChatResponseJob.perform_later(@chat.id, user_message)
  end

  private

  def find_or_create_chat
    chat_id = params[:id] == "new" ? session[:chat_id] : params[:id]

    if chat_id
      Chat.find_by(id: chat_id) || Chat.create!.tap { |c| session[:chat_id] = c.id }
    else
      Chat.create!.tap { |c| session[:chat_id] = c.id }
    end
  end

  def career_context
    @career_context ||= YAML.load_file(Rails.root.join("config/career_context.yml"))
  end
end
