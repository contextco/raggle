# frozen_string_literal: true

class GmailMessage < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy

  def update_and_rechunk!(content, file_metadata)
    transaction do
      update!(payload: file_metadata.to_json)
      document.rechunk!(content)
    end
  end

  def self.create_from_gmail_payload!(content, file_metadata)
    transaction do
      file = create!(payload: file_metadata)
      doc = file.create_document!(stable_id: file_metadata.id, documentable: file)
      doc.rechunk!(content)

      file
    end
  end
end
