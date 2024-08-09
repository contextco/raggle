# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password }
    name { FFaker::Name.name }
    profile_picture_url { FFaker::Internet.uri('https') }

    transient do
      google_oauth_scopes { nil }
    end

    google_oauth do
      {
        'info' => {
          'email' => FFaker::Internet.email,
          'name' => FFaker::Name.name,
          'image' => FFaker::Internet.uri('https')
        },
        'credentials' => {
          'token' => FFaker::IdentificationMX.rfc,
          'scope' => (google_oauth_scopes || %w[email profile openid]).join(' ')
        }
      }
    end
    team
  end
end
