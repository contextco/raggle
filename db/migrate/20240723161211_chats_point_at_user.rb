# frozen_string_literal: true

class ChatsPointAtUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :chats, :team_id, :uuid
    add_reference :chats, :user, type: :uuid, foreign_key: true, index: true
  end
end
