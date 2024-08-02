# frozen_string_literal: true

class Document < ApplicationRecord
  CHUNK_SIZE = 512
  CHUNK_OVERLAP = 32

  belongs_to :message

  has_one_attached :attachment
  has_many :chunks, dependent: :destroy

  has_many :user

  has_many :user_ownerships, class_name: 'UserDocumentOwnership', dependent: :delete_all
  has_many :users, through: :user_ownerships

  delegated_type :documentable, types: %w[UploadedFile]

  after_commit :enqueue_chunk_attachment, on: %i[create update]

  attribute :stable_id, :string, default: -> { SecureRandom.uuid_v7 }

  private

  def enqueue_chunk_attachment
    ChunkAttachmentJob.perform_later(self)
  end
end
