# frozen_string_literal: true

class UploadedFile < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy

  has_one_attached :attachment

  after_commit :chunk_attachment, on: %i[create update]

  private

  def chunk_attachment
    return unless attachment.attached? && document.chunks.empty?

    content = attachment.download
    document.chunks.from_string!(content)
  end
end
