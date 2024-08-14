# frozen_string_literal: true

FactoryBot.define do
  factory :sync_log do
    task_name { 'MyString' }
    started_at { '2020-07-01 00:00:00' }
    ended_at { '2020-07-01 00:05:00' }
    user { nil }
  end
end
