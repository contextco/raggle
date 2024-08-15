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

  def self.search_by_chunks(embedding, scope = Document.all)
    chunks = scope.joins(:chunks)
                  .merge(Chunk.nearest_neighbors(:embedding, embedding, distance: :euclidean).limit(50))

    numbered_chunks = scope
                      .joins("INNER JOIN LATERAL (#{chunks.to_sql}) AS matching_chunks ON matching_chunks.document_id = documents.id")
                      .reselect('documents.id, documents.*, matching_chunks.content AS matching_content')
                      .select('ROW_NUMBER() OVER (PARTITION BY documents.id ORDER BY matching_chunks.neighbor_distance ASC) AS row_num')
                      .order('matching_chunks.neighbor_distance')

    Document.with(numbered_chunks:)
            .from(numbered_chunks, :numbered_chunks)
            .select('numbered_chunks.*')
            .where('row_num = 1')
  end

  def uploaded_file?
    documentable_type == 'UploadedFile'
  end
end
