# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { FFaker::Lorem.sentence }
    role { %w[user assistant].sample }

    chat
  end
end
