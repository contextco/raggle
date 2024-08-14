# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingestors::Google::Docs do
  let(:user) { create(:user, google_oauth_credentials: { 'refresh_token' => 'fake_refresh_token' }) }
  let(:ingestor) { described_class.new(user) }
  let(:mock_client) { instance_double(Google::Apis::DriveV2::DriveService) }
  let(:mock_file) { instance_double(Google::Apis::DriveV2::File, id: 'fake_file_id', title: 'Test Document', modified_date: 1.minute.ago) }
  let(:mock_oauth_client) { instance_double(Signet::OAuth2::Client) }

  before do
    allow(Google::Apis::DriveV2::DriveService).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:authorization=)

    allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_oauth_client)
    allow(mock_oauth_client).to receive(:update!)
    allow(mock_oauth_client).to receive(:fetch_access_token!)
    allow(mock_client).to receive(:authorization).and_return(mock_oauth_client)

    allow(mock_file).to receive(:to_h).and_return({ id: 'fake_file_id', title: 'Test Document' })
  end

  describe '#ingest' do
    let(:mock_file_list) { instance_double(Google::Apis::DriveV2::FileList, items: [mock_file]) }

    before do
      allow(mock_client).to receive(:list_files).and_return(mock_file_list)
      allow(mock_client).to receive(:export_file).and_return('Exported file content')
    end

    it 'fetches Google Docs files' do
      expect(mock_client).to receive(:list_files).with(q: "mimeType = 'application/vnd.google-apps.document'")
      ingestor.ingest
    end

    it 'exports each file' do
      expect(mock_client).to receive(:export_file).with('fake_file_id', 'text/plain')
      ingestor.ingest
    end

    it 'creates a GoogleDriveFile' do
      expect { ingestor.ingest }.to change { user.documents.where(documentable_type: GoogleDriveFile.name).count }.by(1)
    end

    it 'associates the document with the user' do
      ingestor.ingest
      expect(user.documents).to include(GoogleDriveFile.last.document)
    end

    context 'when a document already exists' do
      let!(:google_drive_file) { create(:google_drive_file, document: build(:document, stable_id: 'fake_file_id', last_sync_at: 1.day.ago)) }

      it 'updates the existing document' do
        expect { ingestor.ingest }.to change { google_drive_file.reload.file_payload }.to(mock_file.to_h.stringify_keys)
      end
    end

    context 'when was modified before the last sync time' do
      let!(:google_drive_file) { create(:google_drive_file, document: build(:document, stable_id: 'fake_file_id', last_sync_at: 1.day.ago)) }
      let(:mock_file) { instance_double(Google::Apis::DriveV2::File, id: 'fake_file_id', title: 'Test Document', modified_date: 2.days.ago) }

      it 'does not update the document' do
        expect { ingestor.ingest }.not_to(change { google_drive_file.reload.file_payload })
      end
    end
  end
end
