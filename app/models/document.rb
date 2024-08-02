# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :message

  has_one_attached :attachment
  has_many :chunks, dependent: :destroy

  delegated_type :documentable, types: %w[UploadedFile]
  self.ignored_columns += ['documentable_id']

  after_commit :chunk_attachment, on: %i[create update]

  CHUNK_SIZE = 512
  CHUNK_OVERLAP = 32

  private

  def chunk_attachment
    return unless attachment.attached? && chunks.empty?

    content = attachment.download
    content.each_chunk(CHUNK_SIZE, CHUNK_OVERLAP).with_index do |chunk_content, chunk_index|
      chunks.create!(chunk_index:, content: chunk_content)
    end
  end
end
