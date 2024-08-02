# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    association :message, factory: :message

    documentable factory: :uploaded_file, document: nil

    factory :document_with_chunks do
      transient do
        chunks_count { 5 }
      end

      after(:create) do |document, evaluator|
        create_list(:chunk, evaluator.chunks_count, document:)
      end
    end
  end
end
