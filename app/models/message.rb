class Message < ApplicationRecord
  belongs_to :chat

  attribute :content, :string, default: ''
end
