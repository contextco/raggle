# frozen_string_literal: true

class Chunk < ApplicationRecord
  belongs_to :document

  validates :chunk_index, presence: true
  validates :content, presence: true
end
