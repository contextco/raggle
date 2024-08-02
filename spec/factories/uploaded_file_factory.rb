# frozen_string_literal: true

FactoryBot.define do
  factory :uploaded_file do
    association :document, factory: :document, strategy: :build
  end
end
