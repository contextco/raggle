# frozen_string_literal: true

FactoryBot.define do
  factory :chunk do
    chunk_index { 0 }
    content { 'Sample content' }
    association :document, strategy: :build
  end
end
