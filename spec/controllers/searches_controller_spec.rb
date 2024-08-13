# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchesController, type: :request do
  include ActionView::RecordIdentifier

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /search' do
    it 'returns a success response' do
      get search_path
      expect(response).to be_successful
    end

    context 'when a query is present', vcr: 'controllers/search' do
      let(:google_drive_file) { create(:google_drive_file) }
      let(:drive_file_chunk) { create(:chunk, document: google_drive_file.document, content: 'foo') }

      let(:gmail_message) { create(:gmail_message) }
      let(:gmail_chunk) { create(:chunk, document: gmail_message.document, content: 'foo') }

      before do
        user.documents << google_drive_file.document
        user.documents << gmail_message.document
        drive_file_chunk
        gmail_chunk
      end

      it 'enqueues a search job' do
        expect do
          get search_path, params: { q: 'foo' }
        end.to have_enqueued_job(PerformSearchJob).with('foo', user, anything)
      end

      it 'renders the results for the google drive file' do
        get search_path, params: { q: 'foo' }
        expect(response.body).to include(google_drive_file.title)
      end

      it 'renders the results for the gmail message' do
        get search_path, params: { q: 'foo' }
        expect(response.body).to include(dom_id(gmail_message, :result))
      end
    end
  end
end
