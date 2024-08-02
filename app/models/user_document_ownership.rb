# frozen_string_literal: true

class UserDocumentOwnership < ApplicationRecord
  belongs_to :user
  belongs_to :document
end
