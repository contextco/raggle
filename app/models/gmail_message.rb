# frozen_string_literal: true

class GmailMessage < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy
  encrypts :from, :to, :subject

  def update_and_rechunk!(message_metadata, body:, headers:)
    transaction do
      update!(
        message_metadata_payload: message_metadata,
        from: headers['from'],
        to: headers['to'],
        subject: headers['subject'],
        received_at: Time.at(message_metadata['internal_date'] / 1000) # Convert milliseconds to seconds
      )
      document.rechunk!(body)
    end
  end

  def self.create_from_user_message!(message_metadata, body:, headers:)
    transaction do
      gmail_message = create!(
        message_metadata_payload: message_metadata,
        from: headers['from'],
        to: headers['to'],
        subject: headers['subject'],
        received_at: Time.at(message_metadata['internal_date'] / 1000) # Convert milliseconds to seconds
      )

      document = gmail_message.create_document!(
        stable_id: message_metadata['id'],
        documentable: gmail_message
      )

      document.rechunk!(body)
      gmail_message
    end
  end
end
