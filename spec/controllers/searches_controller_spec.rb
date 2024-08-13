# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchesController, type: :request do
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
      let(:chunk) { create(:chunk, document: google_drive_file.document, content: 'foo') }

      before do
        user.documents << google_drive_file.document
        chunk
      end

      it 'enqueues a search job' do
        expect do
          get search_path, params: { q: 'foo' }
        end.to have_enqueued_job(PerformSearchJob).with('foo', user, anything)
      end

      it 'renders the results template' do
        get search_path, params: { q: 'foo' }
        expect(response.body).to include(google_drive_file.title)
      end
    end
  end
end
