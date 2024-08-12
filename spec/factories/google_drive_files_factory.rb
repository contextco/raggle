# frozen_string_literal: true

FactoryBot.define do
  factory :google_drive_file do
    file_payload { { name: 'test_file' } }

    association :document, factory: :document, strategy: :build
  end
end
