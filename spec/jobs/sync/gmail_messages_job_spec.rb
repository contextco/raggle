# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sync::GmailMessagesJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:gmail_ingestor) { instance_double(Ingestors::Google::Gmail) }

  before do
    allow(Ingestors::Google::Gmail).to receive(:new).with(user).and_return(gmail_ingestor)
  end

  it 'performs the job successfully' do
    allow(gmail_ingestor).to receive(:ingest)

    expect do
      perform_enqueued_jobs do
        described_class.perform_later(user)
      end
    end.to change { user.sync_logs.latest(:gmail)&.completed? }.from(nil).to(true)
  end

  it 'starts and ends logging successfully' do
    allow(gmail_ingestor).to receive(:ingest)

    expect do
      perform_enqueued_jobs do
        Sync::GmailMessagesJob.perform_later(user)
      end.to change { user.sync_logs.latest(:gmail) }.from(nil).to(SyncLog)
    end
  end

  it 'marks the sync log as in progress when the job is enqueued' do
    expect do
      Sync::GmailMessagesJob.perform_later(user)
    end.to change { user.sync_logs.latest(:gmail)&.in_progress? }.from(nil).to(true)
  end

  context 'when the ingestion fails' do
    before do
      allow(gmail_ingestor).to receive(:ingest).and_raise(StandardError.new('Something went wrong'))
    end

    it 'still creates and completes the synclog' do
      perform_enqueued_jobs do
        expect { described_class.perform_later(user) }.to change { user.sync_logs.latest(:gmail)&.completed? }.from(nil).to(true)
      end
    end
  end
end
