# frozen_string_literal: true

class Chunk < ApplicationRecord
  belongs_to :document
  has_neighbors :embedding

  encrypts :content

  validates :chunk_index, presence: true
  validates :content, presence: true

  after_commit :generate_embedding, on: :create

  DEFAULT_SIZE = 512
  DEFAULT_OVERLAP = 32

  def self.from_string!(document, content, with_embedding: true)
    transaction do
      content.each_chunk(DEFAULT_SIZE, DEFAULT_OVERLAP)
             .with_index do |chunk_content, chunk_index|
        embedding = (EmbeddingService.generate(chunk_content) if with_embedding)
        next if document.reload.chunks.exists?(chunk_index:)

        create!(chunk_index:, content: chunk_content, embedding:)
      end
    end
  end

  private

  def generate_embedding
    return if embedding.present?

    GenerateEmbeddingsJob.perform_later(self)
  end
end
