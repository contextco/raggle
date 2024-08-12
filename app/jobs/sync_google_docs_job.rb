# frozen_string_literal: true

class SyncGoogleDocsJob < ApplicationJob
  queue_as :default

  def perform(user)
    google_docs = Ingestors::Google::Docs.new(user)
    google_docs.ingest
  end
end
