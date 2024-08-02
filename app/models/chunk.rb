# frozen_string_literal: true

class Chunk < ApplicationRecord
  belongs_to :document
  has_neighbors :embedding

  encrypts :content

  validates :chunk_index, presence: true
  validates :content, presence: true

  before_create :generate_embedding

  private

  def generate_embedding
    self.embedding = EmbeddingService.generate(content)
  end
end
