# frozen_string_literal: true

class Ingestors::Google::Docs
  def initialize(user)
    client = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      client_id: ENV.fetch('GOOGLE_CLIENT_ID', nil),
      client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET', nil),
      refresh_token: user.google_oauth_credentials['refresh_token']
    )
    client.fetch_access_token!

    @client = client
  end

  def ingest
    files = google_drive_client.list_files(q: 'mimeType = "application/vnd.google-apps.document"').items
    files.each(&method(:persist_or_update_doc))

    nil
  end

  private

  def persist_or_update_doc(file)
    response = google_drive_client.export_file(file.id, 'text/plain')

    document = Document.find_by(stable_id: file.id, documentable_type: GoogleDriveFile.name)
    if document.present?
      document.documentable.update_and_rechunk!(response, file)
    else
      GoogleDriveFile.create_from_google_payload!(response, file)
    end
  end

  def google_drive_client
    @google_drive_client ||= Google::Apis::DriveV2::DriveService.new.tap do |drive|
      drive.authorization = client
    end
  end

  attr_reader :client
end
