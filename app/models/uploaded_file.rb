# frozen_string_literal: true

class UploadedFile < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy

  has_one_attached :attachment

  after_commit :chunk_attachment_in_background, on: %i[create update]

  private

  def chunk_attachment_in_background
    ChunkAttachmentJob.perform_later(self)
  end
end
