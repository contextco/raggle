# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get settings_path
      expect(response).to be_successful
    end

    context 'when google drive is not authorized' do
      it 'shows a link to authorize google drive' do
        get settings_path
        expect(response.body).to include(auth_provider_path(provider: :google_with_google_drive))
      end
    end

    context 'when google drive is authorized' do
      let(:user) { create(:user, google_oauth_scopes: [Ingestors::Google::Docs::REQUIRED_SCOPE]) }

      it 'shows that the google drive integration is connected' do
        get settings_path
        expect(response.body).to include('google-drive-integration-connected')
      end
    end

    context 'when gmail is not authorized' do
      it 'shows a link to authorize gmail' do
        get settings_path
        expect(response.body).to include(auth_provider_path(provider: :google_with_gmail))
      end
    end

    context 'when gmail is authorized' do
      let(:user) { create(:user, google_oauth_scopes: [Ingestors::Google::Gmail::REQUIRED_SCOPE]) }

      it 'shows that the gmail integration is connected' do
        get settings_path
        expect(response.body).to include('gmail-integration-connected')
      end
    end
  end
end
