class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :messages
end
