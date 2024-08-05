# frozen_string_literal: true

class GenerateEmbeddingsJob < ApplicationJob
  queue_as :default

  def perform(record, field: :embedding)
    return if record.send(field).present?

    embeddings = EmbeddingService.generate(record.content)
    record.update!(field => embeddings)
  end
end
