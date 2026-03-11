class Message < ApplicationRecord
  acts_as_message
  has_many_attached :attachments

  belongs_to :chat
  belongs_to :model, optional: true

  validates :role, presence: true
  validates :content, presence: true
end
