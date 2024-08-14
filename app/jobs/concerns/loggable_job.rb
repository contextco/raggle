# frozen_string_literal: true

module LoggableJob
  extend ActiveSupport::Concern

  included do
    before_enqueue :log_sync_start

    rescue_from StandardError, with: :mark_task_as_completed
    after_perform :mark_task_as_completed
  end

  private

  def log_sync_start
    user.sync_logs.start!(task_name: integration.key)
  end

  def mark_task_as_completed
    user.sync_logs.latest(integration.key)&.mark_as_completed!
  end

  def integration
    @integration ||= Integration.from_backfill_job(self.class)
  end

  def user
    arguments.first
  end
end
