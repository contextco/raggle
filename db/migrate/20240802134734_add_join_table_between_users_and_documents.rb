# frozen_string_literal: true

class AddJoinTableBetweenUsersAndDocuments < ActiveRecord::Migration[7.1]
  def change
    create_join_table :users, :documents, table_name: :user_document_ownerships do |t|
      t.index :user_id
      t.index :document_id
    end
  end
end
