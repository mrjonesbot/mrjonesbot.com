class AddSessionTokenToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :session_token, :string
    add_index :chats, :session_token
  end
end
