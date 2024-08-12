# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe '.from_omniauth' do
    context 'when the user already exists' do
      let!(:user) { create(:user, email: 'alex@example.com') }
      subject(:result) { described_class.from_omniauth(auth) }

      let(:auth) do
        OmniAuth::AuthHash.new(
          provider: 'google',
          uid: '123545',
          info: {
            email: 'alex@example.com',
            name: 'A changed name',
            image: 'https://example.com/image.jpg'
          },
          credentials: {
            refresh_token: 'refresh_token'
          }
        )
      end

      it 'updates the name' do
        expect { result }.to change { user.reload.name }.to('A changed name')
      end

      it 'updates the profile picture url' do
        expect { result }.to change { user.reload.profile_picture_url }.to('https://example.com/image.jpg')
      end

      it 'does not update the credentials' do
        expect { result }.not_to(change { user.reload.google_oauth_credentials })
      end
    end
  end
end
