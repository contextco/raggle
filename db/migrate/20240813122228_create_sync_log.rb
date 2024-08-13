# frozen_string_literal: true

class CreateSyncLog < ActiveRecord::Migration[7.1]
  def change
    create_table :sync_logs, id: :uuid do |t|
      t.string :task_name, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.timestamps
    end
  end
end
