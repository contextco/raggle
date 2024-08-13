# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sync::GmailMessagesJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:gmail_ingestor) { instance_double(Ingestors::Google::Gmail) }

  before do
    allow(Ingestors::Google::Gmail).to receive(:new).with(user).and_return(gmail_ingestor)
    allow(gmail_ingestor).to receive(:ingest)
    allow(SyncLog).to receive(:start).and_return(double('SyncLog', mark_as_completed!: true))
  end

  it 'performs the job' do
    perform_enqueued_jobs do
      Sync::GmailMessagesJob.perform_later(user)
      expect(Ingestors::Google::Gmail).to have_received(:new).with(user)
      expect(gmail_ingestor).to have_received(:ingest)
    end
  end

  it 'starts and ends logging' do
    perform_enqueued_jobs do
      expect(SyncLog).to receive(:start).with(task_name: 'Sync::GmailMessagesJob', user:).and_return(double('SyncLog', mark_as_completed!: true))
      Sync::GmailMessagesJob.perform_later(user)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
