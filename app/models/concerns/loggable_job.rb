# frozen_string_literal: true

module LoggableJob
  extend ActiveSupport::Concern

  included do
    before_perform :start_logging
    after_perform :end_logging
  end

  private

  def start_logging
    @log = SyncLog.start(task_name: self.class.name, user: arguments.first)
  end

  def end_logging
    @log.mark_as_completed!
  end
end
