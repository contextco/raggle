# frozen_string_literal: true

class SyncLog < ApplicationRecord
  belongs_to :user

  validates :task_name, presence: true
  validates :started_at, presence: true
  validates :user, presence: true

  def self.start(task_name:, user:)
    create!(task_name:, user:, started_at: Time.current)
  end

  def mark_as_completed!
    update!(ended_at: Time.current)
  end
end
