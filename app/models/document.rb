# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :message, optional: true

  has_many :chunks, dependent: :destroy

  has_many :user_ownerships, class_name: 'UserDocumentOwnership', dependent: :delete_all
  has_many :users, through: :user_ownerships
  delegate :attachment, to: :documentable

  delegated_type :documentable, types: %w[UploadedFile]

  attribute :stable_id, :string, default: -> { SecureRandom.uuid_v7 }


def rechunk!(content)
    transaction do
        chunks.delete_all
        chunks.from_string!(content)
    end
end

  def uploaded_file?
    documentable_type == 'UploadedFile'
  end
end
