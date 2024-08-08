# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchesController do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /search' do
    it 'returns a success response' do
      get :show
      expect(response).to be_successful
    end

    context 'when a query is present' do
      it 'performs a search' do
        expect(controller).to receive(:perform_search)
        get :show, params: { q: 'foo' }
      end

      it 'enqueues a search job' do
        expect do
          get :show, params: { q: 'foo' }
        end.to have_enqueued_job(PerformSearchJob).with('foo', user, anything)
      end
    end
  end
end
