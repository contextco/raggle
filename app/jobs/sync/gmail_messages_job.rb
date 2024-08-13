# frozen_string_literal: true

class Sync::GmailMessagesJob < ApplicationJob
  include LoggableJob

  queue_as :default

  def perform(user)
    gmail = Ingestors::Google::Gmail.new(user)
    gmail.ingest
  end
end
