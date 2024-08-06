# frozen_string_literal: true

class AddLastSyncFieldToDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :last_sync_at, :datetime, default: 'CURRENT_TIMESTAMP'
  end
end
