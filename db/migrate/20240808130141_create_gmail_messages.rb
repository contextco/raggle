# frozen_string_literal: true

class CreateGmailMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :gmail_messages, id: :uuid do |t|
      t.string :payload

      t.timestamps
    end
  end
end
