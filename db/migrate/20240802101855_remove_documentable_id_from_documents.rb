# frozen_string_literal: true

class RemoveDocumentableIdFromDocuments < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :documents, :documentable_id, :integer }
  end
end
