# frozen_string_literal: true

class Document < ApplicationRecord
  CHUNK_SIZE = 512
  CHUNK_OVERLAP = 32

  belongs_to :message

  has_one_attached :attachment
  has_many :chunks, dependent: :destroy

  delegated_type :documentable, types: %w[UploadedFile]

  after_commit :chunk_attachment, on: %i[create update]

  private

  def chunk_attachment
    return unless attachment.attached? && chunks.empty?

    content = attachment.download
    content.each_chunk(CHUNK_SIZE, CHUNK_OVERLAP).with_index do |chunk_content, chunk_index|
      chunks.create!(chunk_index:, content: chunk_content)
    end
  end
end
