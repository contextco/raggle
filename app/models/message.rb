# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :chat

  attribute :content, :string, default: ''

  has_many :documents, dependent: :destroy

  enum role: %w[user assistant system].index_by(&:to_sym), _suffix: true

  def attach(files_to_attach, uploaded_by:)
    ActiveRecord::Base.transaction do
      files_to_attach.each do |file|
        next unless file.present?

        doc = documents.create!(documentable: UploadedFile.create!)
        doc.attachment.attach(file)

        uploaded_by.document_ownerships.create!(document: doc)
      end
    end
  end
end
