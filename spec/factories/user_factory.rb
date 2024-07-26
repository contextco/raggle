# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password }
    name { FFaker::Name.name }
    profile_picture_url { FFaker::Internet.uri('https') }
    team
  end
end
