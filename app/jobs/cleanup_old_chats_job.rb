class CleanupOldChatsJob < ApplicationJob
  queue_as :default

  def perform
    # Delete chats older than 1 day
    deleted_count = Chat.where("created_at < ?", 1.day.ago).destroy_all.size

    Rails.logger.info "CleanupOldChatsJob: Deleted #{deleted_count} chats older than 1 day"
  end
end
