# frozen_string_literal: true

class AddEmbeddingIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :chunks, :embedding, using: :hnsw, opclass: :vector_l2_ops, algorithm: :concurrently
  end
end
