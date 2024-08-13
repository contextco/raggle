# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingestors::Google::Gmail do
  let(:user) { create(:user, google_oauth_credentials: { 'refresh_token' => 'fake_refresh_token' }) }
  let(:ingestor) { described_class.new(user) }
  let(:mock_oauth_client) { instance_double(Signet::OAuth2::Client) }
  let(:mock_client) { instance_double(Google::Apis::GmailV1::GmailService) }
  let(:mock_message) do
    instance_double(Google::Apis::GmailV1::Message, id: 'message_id', internal_date: Time.current.to_i * 1000,
                                                    payload: instance_double(Google::Apis::GmailV1::MessagePart, headers: [instance_double(Google::Apis::GmailV1::MessagePartHeader, name: 'Subject', value: 'Test Subject')],
                                                                                                                 body: instance_double(Google::Apis::GmailV1::MessagePartBody, data: '<p>Test Body</p>')))
  end

  before do
    allow(Google::Apis::GmailV1::GmailService).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:authorization=).with(mock_oauth_client)

    allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_oauth_client)
    allow(mock_oauth_client).to receive(:fetch_access_token!)
    allow(mock_client).to receive(:authorization).and_return(mock_oauth_client)
    allow(mock_message).to receive(:to_h).and_return({ id: 'message_id', internal_date: Time.current.to_i * 1000, raw: '123123' })
  end

  describe '#ingest' do
    let(:mock_message_list) { instance_double(Google::Apis::GmailV1::ListMessagesResponse, messages: [mock_message], next_page_token: nil) }

    before do
      allow(mock_client).to receive(:list_user_messages).and_return(mock_message_list)
      allow(mock_client).to receive(:get_user_message).and_return(mock_message)
    end

    it 'fetches Google Gmail messages' do
      expect(mock_client).to receive(:list_user_messages).with('me', include_spam_trash: false,
                                                                     q: 'in:anywhere', max_results: 100, page_token: nil)
      ingestor.ingest
    end

    it 'exports each message' do
      expect(mock_client).to receive(:get_user_message).with('me', 'message_id', format: 'full')
      ingestor.ingest
    end

    it 'creates a GmailMessage' do
      expect { ingestor.ingest }.to change { user.documents.where(documentable_type: GmailMessage.name).count }.by(1)
    end

    it 'associates the document with the user' do
      ingestor.ingest
      expect(user.documents.where(documentable_type: GmailMessage.name)).to include(GmailMessage.last.document)
    end

    it 'strips HTML tags from the message body' do
      expect { ingestor.ingest }.to change { user.documents.where(documentable_type: GmailMessage.name).count }.by(1)
      expect(GmailMessage.last.document.chunks.first.content).to eq('Test Body')
    end

    context 'when a document already exists' do
      let!(:existing_document) { create(:document, stable_id: 'message_id', last_sync_at: 1.day.ago) }
      let!(:gmail_message) { create(:gmail_message, document: existing_document) }

      it 'updates the existing document' do
        expect { ingestor.ingest }.to change { gmail_message.reload.message_metadata_payload }.to(mock_message.to_h.except(:raw).stringify_keys)
      end
    end

    context 'when the message was modified before the last sync time' do
      let!(:existing_document) { create(:document, stable_id: 'message_id', last_sync_at: 1.day.ago) }
      let!(:gmail_message) { create(:gmail_message, document: existing_document) }
      let(:mock_message) { instance_double(Google::Apis::GmailV1::Message, id: 'message_id', internal_date: 2.days.ago.to_i) }

      it 'does not update the existing document' do
        expect { ingestor.ingest }.not_to(change { gmail_message.reload.message_metadata_payload })
      end
    end

    context 'when the message has non-English characters' do
      let(:mock_message) do
        instance_double(Google::Apis::GmailV1::Message, id: 'message_id', internal_date: Time.current.to_i * 1000,
                                                        payload: instance_double(Google::Apis::GmailV1::MessagePart, headers: [instance_double(Google::Apis::GmailV1::MessagePartHeader, name: 'Subject', value: 'Test Subject')],
                                                                                                                     body: instance_double(Google::Apis::GmailV1::MessagePartBody, data: '👋🌎')))
      end

      it 'exports the message' do
        expect { ingestor.ingest }.to change { user.documents.where(documentable_type: GmailMessage.name).count }.by(1)
      end
    end
  end
end
