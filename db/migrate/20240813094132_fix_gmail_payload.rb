# frozen_string_literal: true

class FixGmailPayload < ActiveRecord::Migration[7.1]
  def change
    add_column :gmail_messages, :message_metadata_payload, :jsonb

    safety_assured do
      remove_column :gmail_messages, :payload
    end
  end
end
