# frozen_string_literal: true

class CreateChunks < ActiveRecord::Migration[7.1]
  def change
    create_table :chunks, id: :uuid do |t|
      t.references :document, null: false, foreign_key: true, type: :uuid
      t.integer :chunk_index, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :chunks, %i[document_id chunk_index], unique: true
  end
end
