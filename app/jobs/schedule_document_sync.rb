# frozen_string_literal: true

class ScheduleDocumentSync < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      SyncGmailMessagesJob.perform_later(user) if user.gmail_permission_granted?
    end
  end
end
