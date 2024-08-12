# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :message, optional: true

  has_many :chunks, dependent: :destroy

  has_many :user_ownerships, class_name: 'UserDocumentOwnership', dependent: :delete_all
  has_many :users, through: :user_ownerships
  delegate :attachment, to: :documentable

  delegated_type :documentable, types: %w[UploadedFile GoogleDriveFile GmailMessage], dependent: :destroy

  attribute :stable_id, :string, default: -> { SecureRandom.uuid_v7 }

  attribute :last_sync_at, :datetime, default: -> { Time.current }

  def rechunk!(content)
    transaction do
      chunks.delete_all
      chunks.from_string!(self, content)
    end
  end

  def self.search_by_chunks(embedding)
    chunks = joins(:chunks)
             .merge(Chunk.nearest_neighbors(:embedding, embedding, distance: :euclidean))

    joins("INNER JOIN LATERAL (#{chunks.to_sql}) AS matching_chunks ON matching_chunks.document_id = documents.id")
      .group('documents.id')
      .reselect('documents.id, documents.*, MIN(matching_chunks.neighbor_distance) AS neighbor_distance')
      .order('MIN(matching_chunks.neighbor_distance) ASC')
  end

  def uploaded_file?
    documentable_type == 'UploadedFile'
  end
end
