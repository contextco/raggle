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

  after_commit :chunk_attachment, on: %i[create update]

  attribute :stable_id, :string, default: -> { SecureRandom.uuid_v7 }

  private

  def chunk_attachment
    return unless attachment.attached? && chunks.empty?

    content = attachment.download
    content.each_chunk(CHUNK_SIZE, CHUNK_OVERLAP).with_index do |chunk_content, chunk_index|
      chunks.create!(chunk_index:, content: chunk_content)
    end
  end
end
