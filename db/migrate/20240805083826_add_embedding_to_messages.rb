# frozen_string_literal: true

class AddEmbeddingToMessages < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'vector' unless extension_enabled?('vector')

    add_column :messages, :embedding, :vector, limit: 1536
  end
end
