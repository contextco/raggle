# frozen_string_literal: true

class GmailMessage < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy
  encrypts :payload, :from, :to, :subject

  def update_and_rechunk!(message, body:, headers:)
    transaction do
      update!(payload: message.to_json,
              from: headers['from'],
              to: headers['to'],
              subject: headers['subject'],
              received_at: Time.at(message.internal_date / 1000)) # Convert milliseconds to seconds
      document.rechunk!(body)
    end
  end

  def self.create_from_user_message!(message, body:, headers:)
    transaction do
      gmail_message = create!(
        payload: message.to_json,
        from: headers['from'],
        to: headers['to'],
        subject: headers['subject'],
        received_at: Time.at(message.internal_date / 1000) # Convert milliseconds to seconds
      )

      document = gmail_message.create_document!(
        stable_id: message.id,
        documentable: gmail_message
      )

      document.rechunk!(body)
      gmail_message
    end
  end
end
