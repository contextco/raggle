# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :chat

  attribute :content, :string, default: ''

  has_many :documents, dependent: :destroy

  enum role: %w[user assistant system].index_by(&:to_sym), _suffix: true

  def attach(documents_to_attach)
    ActiveRecord::Base.transaction do
      documents_to_attach.each do |document|
        next unless document.present?

        documents.create!(documentable: UploadedFile.create!).attachment.attach(document)
      end
    end
  end
end
