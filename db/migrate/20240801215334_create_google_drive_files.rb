class CreateGoogleDriveFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :google_drive_files, id: :uuid do |t|
      t.string :payload

      t.timestamps
    end

    change_column_null :documents, :message_id, true
  end
end
