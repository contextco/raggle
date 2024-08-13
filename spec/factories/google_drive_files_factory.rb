# frozen_string_literal: true

FactoryBot.define do
  factory :google_drive_file do
    file_payload do
      {
        title: 'test_file',
        owners: [
          { display_name: 'Test User', email_address: 'test@example.com', picture: { url: 'http://example.com/picture.jpg' } }
        ],
        modified_date: 2.days.ago.to_s,
        alternate_link: 'http://example.com/file'
      }
    end

    association :document, factory: :document, strategy: :build
  end
end
