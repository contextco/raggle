# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    model { 'gpt-4o-mini' }
    user
  end
end
