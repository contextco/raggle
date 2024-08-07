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
  end

  describe 'POST /search' do
    it 'creates a search' do
      expect do
        post :create, params: { q: 'foo' }, as: :turbo_stream
      end.to have_enqueued_job(PerformSearchJob).with('foo', user, anything)
    end
  end
end
