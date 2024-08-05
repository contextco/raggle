# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :chat
  has_neighbors :embedding

  attribute :content, :string, default: ''

  has_many :documents, dependent: :destroy
  has_many :uploaded_files, through: :documents, source: :documentable, source_type: 'UploadedFile'

  enum role: %w[user assistant system].index_by(&:to_sym), _suffix: true

  after_commit :generate_embedding, on: %i[create update]

  def attach(files_to_attach, uploaded_by:)
    ActiveRecord::Base.transaction do
      files_to_attach.each do |file|
        next unless file.present?

        uploaded_file = UploadedFile.create!
        uploaded_file.attachment.attach(file)
        doc = documents.create!(documentable: uploaded_file)

        uploaded_by.document_ownerships.create!(document: doc)
      end
    end
  end

  def top_k_chunks_grouped_by_document(count: 5)
    return [] if content.blank? || documents.empty? || count <= 0

    chunks = documents.flat_map(&:chunks)
    chunks_with_embeddings = Chunk.where(id: chunks.map(&:id))
    top_chunks = chunks_with_embeddings.nearest_neighbors(:embedding, embedding, distance: :cosine).first(count)

    top_chunks.group_by(&:document)
  end

  private

  def generate_embedding
    return unless saved_change_to_content? && content.present?

    GenerateEmbeddingsJob.perform_later(self)
  end
end
