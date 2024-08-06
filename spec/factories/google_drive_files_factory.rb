# frozen_string_literal: true

FactoryBot.define do
  factory :google_drive_file do
    payload { { name: 'test_file' }.to_json }

    association :document, factory: :document, strategy: :build
  end
end
