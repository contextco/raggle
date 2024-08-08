# frozen_string_literal: true

FactoryBot.define do
  factory :gmail_message do
    payload do
      {
        id: '17b8f1d1b1b1b1b1',
        threadId: '17b8f1d1b1b1b1b1',
        labelIds: %w[UNREAD INBOX],
        snippet: 'This is a test email',
        historyId: '123456',
        internalDate: '123456'
      }.to_json
    end

    association :document, factory: :document, strategy: :build
  end
end
