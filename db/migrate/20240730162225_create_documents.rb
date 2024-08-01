# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents, id: :uuid do |t|
      t.references :message, null: false, foreign_key: true, type: :uuid
      t.string :documentable_type
      t.integer :documentable_id

      t.timestamps
    end
    add_index :documents, %i[documentable_type documentable_id]
  end
end
