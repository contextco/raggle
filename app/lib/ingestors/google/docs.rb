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
    drive = Google::Apis::DriveV2::DriveService.new
    drive.authorization = client

    files = drive.list_files(q: 'mimeType = "application/vnd.google-apps.document"').items
    files.each(&method(:persist_or_update_doc))

    nil
  end

  private

  def persist_or_update_doc(file)
    google_doc_data = fetch_document(file.id)

    document = Document.find_by(stable_id: file.id, entryable_type: GoogleDriveFile.name)
    if document.present?
      document.documentable.update_and_rechunk!(google_doc_data.body, file)
    else
      GoogleDriveFile.create_from_google_payload!(google_doc_data.body, file)
    end
  end

  def fetch_document(document_id)
    doc = Google::Apis::DocsV1::DocsService.new
    doc.authorization = client

    doc.get_document(document_id)
  end

  attr_reader :client
end
