# frozen_string_literal: true

module LoggableJob
  extend ActiveSupport::Concern

  included do
    around_perform :log_task
  end

  private

  def log_task
    mark_task_as_started
    yield
    mark_task_as_completed
  rescue StandardError => e
    mark_task_as_completed
    raise e
  end

  def mark_task_as_started
    log
  end

  def mark_task_as_completed
    log.mark_as_completed!
  end

  def log
    @log ||= SyncLog.start(task_name: self.class.name, user: arguments.first)
  end
end
