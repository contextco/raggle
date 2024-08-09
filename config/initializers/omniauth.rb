# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID', nil), ENV.fetch('GOOGLE_CLIENT_SECRET', nil), {
    scope: [
      Ingestors::Google::Docs::REQUIRED_SCOPE
    ].join(' '),
    name: :google_with_google_drive,
    include_granted_scopes: true,
    prompt: 'consent',
    callback_path: '/_/permissions/google/callback'
  }

  provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID', nil), ENV.fetch('GOOGLE_CLIENT_SECRET', nil), {
    scope: [
      Ingestors::Google::Gmail::REQUIRED_SCOPE
    ].join(' '),
    name: :google_with_gmail,
    include_granted_scopes: true,
    prompt: 'consent',
    callback_path: '/_/permissions/google/callback'
  }
end
