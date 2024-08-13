# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sync::GoogleDocsJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:google_docs_ingestor) { instance_double(Ingestors::Google::Docs) }

  before do
    allow(Ingestors::Google::Docs).to receive(:new).with(user).and_return(google_docs_ingestor)
    allow(google_docs_ingestor).to receive(:ingest)
    allow(SyncLog).to receive(:start).and_return(double('SyncLog', mark_as_completed!: true))
  end

  it 'performs the job' do
    perform_enqueued_jobs do
      Sync::GoogleDocsJob.perform_later(user)
      expect(Ingestors::Google::Docs).to have_received(:new).with(user)
      expect(google_docs_ingestor).to have_received(:ingest)
    end
  end

  it 'starts and ends logging' do
    perform_enqueued_jobs do
      expect(SyncLog).to receive(:start).with(task_name: :google_docs, user:).and_return(double('SyncLog', mark_as_completed!: true))
      Sync::GoogleDocsJob.perform_later(user)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
