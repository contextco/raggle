class Message < ApplicationRecord
  belongs_to :chat

  attribute :content, :string, default: ''

  has_many_attached :files
end
