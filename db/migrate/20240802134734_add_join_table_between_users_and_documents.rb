# frozen_string_literal: true

class AddJoinTableBetweenUsersAndDocuments < ActiveRecord::Migration[7.1]
  def change
    create_join_table :users, :documents, table_name: :user_document_ownerships, column_options: { type: :uuid } do |t|
      t.index :user_id
      t.index :document_id
      t.index %i[user_id document_id], unique: true
    end
  end
end
