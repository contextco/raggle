# frozen_string_literal: true

module LoggableJob
  extend ActiveSupport::Concern

  included do
    around_perform :log_task
  end

  private

  def log_task
    @log = SyncLog.start(task_name: self.class.name, user: arguments.first)
    yield
    @log.mark_as_completed!
  rescue StandardError => e
    mark_completed
    raise e
  end

  def mark_completed
    @log.mark_as_completed!
  end
end
