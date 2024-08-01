# frozen_string_literal: true

class AddEmbeddingToChunks < ActiveRecord::Migration[7.1]
  def change
    add_column :chunks, :embedding, :vector, limit: 1536
  end
end
