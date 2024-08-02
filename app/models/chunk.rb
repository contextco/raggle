# frozen_string_literal: true

class Chunk < ApplicationRecord
  belongs_to :document
  has_neighbors :embedding

  encrypts :content

  validates :chunk_index, presence: true
  validates :content, presence: true

  before_create :generate_embedding

DEFAULT_SIZE = 512
DEFAULT_OVERLAP = 32


  private
  
  
  
  def self.from_string!(content)
  content.each_chunk(DEFAULT_SIZE, DEFAULT_OVERLAP)
  .with_index do |chunk_content, chunk_index|
  chunks.create!(chunk_index:, content: chunk_content)
end
end

  def generate_embedding
    self.embedding = EmbeddingService.generate(content)
  end
end
