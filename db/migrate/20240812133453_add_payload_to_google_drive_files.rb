class AddPayloadToGoogleDriveFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :google_drive_files, :file_payload, :jsonb

    safety_assured { remove_column :google_drive_files, :payload }
  end
end
