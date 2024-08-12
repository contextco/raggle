# frozen_string_literal: true

class GoogleDriveFile < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy

  store_accessor :file_payload, :title

  def update_and_rechunk!(content, file_metadata)
    transaction do
      update!(file_payload: file_metadata.to_h)
      document.rechunk!(content)
    end
  end

  def self.create_from_google_payload!(content, file_metadata)
    transaction do
      file = create!(file_payload: file_metadata.to_h)
      doc = file.create_document!(stable_id: file_metadata.id, documentable: file)
      doc.rechunk!(content)

      file
    end
  end
end
