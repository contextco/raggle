# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :chat

  attribute :content, :string, default: ''

  has_many_attached :files

  enum role: %w[user assistant system].index_by(&:to_sym), _suffix: true
end
