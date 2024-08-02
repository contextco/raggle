# frozen_string_literal: true

class GenerateEmbeddingsJob < ApplicationJob
  queue_as :default

  def perform(record, field: :embedding)
    embeddings = EmbeddingService.generate(record.content)
    record.update!(field => embeddings)
  end
end
