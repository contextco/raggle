# frozen_string_literal: true

class AddFieldsToGmailMessages < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      add_column :gmail_messages, :from, :string
      add_column :gmail_messages, :to, :string
      add_column :gmail_messages, :subject, :string
      add_column :gmail_messages, :received_at, :datetime
    end
  end
end
