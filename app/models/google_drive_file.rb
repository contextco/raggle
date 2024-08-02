class GoogleDriveFile < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy

  def update_and_rechunk!(content, file_metadata)
    transaction do
      update!(payload: file_metadata.to_json)
      document.rechunk!(content)
    end
  end

  def self.create_from_google_payload!(content, file_metadata)
    transaction do
      file = create!(google_id: file_metadata.id)
      file.document.create_and_chunk!(content, stable_id: file_metadata.id, documentable: file)
    end
  end
end
