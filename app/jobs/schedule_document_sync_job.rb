# frozen_string_literal: true

class ScheduleDocumentSyncJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      Sync::GmailMessagesJob.perform_later(user) if user.gmail_permission_granted?
      Sync::GoogleDocsJob.perform_later(user) if user.google_docs_permission_granted?
    end
  end
end
