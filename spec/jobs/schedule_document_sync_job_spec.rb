# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleDocumentSyncJob, type: :job do
  let(:user_with_gmail_permission) { create(:user) }
  let(:user_with_google_docs_permission) { create(:user) }
  let(:user_with_both_permissions) { create(:user) }
  let(:user_with_no_permissions) { create(:user) }

  before do
    allow(user_with_both_permissions).to receive(:gmail_permission_granted?).and_return(true)
    allow(user_with_both_permissions).to receive(:google_docs_permission_granted?).and_return(true)
    allow(user_with_no_permissions).to receive(:gmail_permission_granted?).and_return(false)
    allow(user_with_no_permissions).to receive(:google_docs_permission_granted?).and_return(false)
    allow(user_with_gmail_permission).to receive(:gmail_permission_granted?).and_return(true)
    allow(user_with_google_docs_permission).to receive(:google_docs_permission_granted?).and_return(true)
  end

  it 'schedules SyncGmailMessagesJob for users with Gmail permission' do
    allow(User).to receive(:find_each).and_yield(user_with_gmail_permission)
    expect(SyncGmailMessagesJob).to receive(:perform_later).with(user_with_gmail_permission)
    described_class.perform_now
  end

  it 'schedules SyncGoogleDocsJob for users with Google Docs permission' do
    allow(User).to receive(:find_each).and_yield(user_with_google_docs_permission)
    expect(SyncGoogleDocsJob).to receive(:perform_later).with(user_with_google_docs_permission)
    described_class.perform_now
  end

  it 'schedules both SyncGmailMessagesJob and SyncGoogleDocsJob for users with both permissions' do
    allow(User).to receive(:find_each).and_yield(user_with_both_permissions)
    expect(SyncGmailMessagesJob).to receive(:perform_later).with(user_with_both_permissions)
    expect(SyncGoogleDocsJob).to receive(:perform_later).with(user_with_both_permissions)
    described_class.perform_now
  end

  it 'does not schedule any jobs for users with no permissions' do
    allow(User).to receive(:find_each).and_yield(user_with_no_permissions)
    expect(SyncGmailMessagesJob).not_to receive(:perform_later)
    expect(SyncGoogleDocsJob).not_to receive(:perform_later)
    described_class.perform_now
  end
end
