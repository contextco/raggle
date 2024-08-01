# frozen_string_literal: true

class UploadedFile < ApplicationRecord
  has_one :document, as: :documentable, dependent: :destroy
end
