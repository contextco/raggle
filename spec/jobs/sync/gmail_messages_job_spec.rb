# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sync::GmailMessagesJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:gmail_ingestor) { instance_double(Ingestors::Google::Gmail) }
  let(:sync_log) { instance_double(SyncLog, mark_as_completed!: true) }

  before do
    allow(Ingestors::Google::Gmail).to receive(:new).with(user).and_return(gmail_ingestor)
    allow(SyncLog).to receive(:start).and_return(sync_log)
  end

  it 'performs the job successfully' do
    allow(gmail_ingestor).to receive(:ingest)

    perform_enqueued_jobs do
      Sync::GmailMessagesJob.perform_later(user)
      expect(Ingestors::Google::Gmail).to have_received(:new).with(user)
      expect(gmail_ingestor).to have_received(:ingest)
      expect(sync_log).to have_received(:mark_as_completed!)
    end
  end

  it 'starts and ends logging successfully' do
    allow(gmail_ingestor).to receive(:ingest)

    perform_enqueued_jobs do
      expect(SyncLog).to receive(:start).with(task_name: 'Sync::GmailMessagesJob', user:).and_return(sync_log)
      expect(sync_log).to receive(:mark_as_completed!)
      Sync::GmailMessagesJob.perform_later(user)
    end
  end

  it 'handles failure and marks log as completed' do
    allow(gmail_ingestor).to receive(:ingest).and_raise(StandardError.new('Something went wrong'))

    expect do
      Sync::GmailMessagesJob.perform_now(user)
    end.to raise_error(StandardError, 'Something went wrong')

    expect(SyncLog).to have_received(:start).with(task_name: 'Sync::GmailMessagesJob', user:)
    expect(sync_log).to have_received(:mark_as_completed!)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
