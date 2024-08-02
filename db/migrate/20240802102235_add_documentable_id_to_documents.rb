# frozen_string_literal: true

class AddDocumentableIdToDocuments < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :documents, :documentable_id, :uuid, null: true
    add_index :documents, %i[documentable_id documentable_type], name: 'index_documents_on_documentable_id_and_type', algorithm: :concurrently
  end
end
