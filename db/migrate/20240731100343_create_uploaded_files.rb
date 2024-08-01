# frozen_string_literal: true

class CreateUploadedFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :uploaded_files, id: :uuid, &:timestamps
  end
end
