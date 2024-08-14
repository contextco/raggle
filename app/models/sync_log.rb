# frozen_string_literal: true

class SyncLog < ApplicationRecord
  belongs_to :user

  validates :task_name, presence: true
  validates :started_at, presence: true
  validates :user, presence: true

  def self.start!(task_name:)
    raise StandardError, 'cannot start a task when one is already in progress' if latest(task_name)&.in_progress?

    create!(task_name:, started_at: Time.current)
  end

  def mark_as_completed!
    raise StandardError, 'cannot mark a task as completed when it is already completed' if completed?

    update!(ended_at: Time.current)
  end

  def self.latest(key)
    where(task_name: key).order(started_at: :desc).first
  end

  def in_progress?
    ended_at.nil?
  end

  def completed?
    !in_progress?
  end
end
