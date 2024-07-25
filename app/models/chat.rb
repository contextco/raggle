class Chat < ApplicationRecord
  has_one :first_message, -> { order(created_at: :asc) }, class_name: 'Message'
  has_many :messages, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :messages
end
