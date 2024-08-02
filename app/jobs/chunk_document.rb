# frozen_string_literal: true

class ChunkDocumentJob < ApplicationJob
  queue_as :default

  def perform(document, content)
    return unless document.attachment.attached? && document.chunks.empty?

    content = document.attachment.download
    content.each_chunk(Document::CHUNK_SIZE, Document::CHUNK_OVERLAP).with_index do |chunk_content, chunk_index|
      document.chunks.create!(chunk_index:, content: chunk_content)
    end
  end
end
