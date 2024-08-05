# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :message

  has_many :chunks, dependent: :destroy

  has_many :user_ownerships, class_name: 'UserDocumentOwnership', dependent: :delete_all
  has_many :users, through: :user_ownerships
  delegate :attachment, to: :documentable

  delegated_type :documentable, types: %w[UploadedFile]

  attribute :stable_id, :string, default: -> { SecureRandom.uuid_v7 }

  def uploaded_file?
    documentable_type == 'UploadedFile'
  end
end
