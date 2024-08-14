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
    @user = user
  end

  REQUIRED_SCOPE = 'https://www.googleapis.com/auth/drive.readonly'

  def ingest
    files = google_drive_client.list_files(q: search_query).items
    files.each(&method(:persist_or_update_doc))

    nil
  end

  private

  def persist_or_update_doc(file)
    document = Document.find_by(stable_id: file.id, documentable_type: GoogleDriveFile.name)
    return if document&.last_sync_at.present? && document.last_sync_at > file.modified_date

    response = google_drive_client.export_file(file.id, 'text/plain')

    Document.transaction do
      if document.present?
        document.documentable.update_and_rechunk!(response, file)
        UserDocumentOwnership.upsert({ user_id: user.id, document_id: document.id }, unique_by: %i[user_id document_id])
      else
        drive_file = GoogleDriveFile.create_from_google_payload!(response, file)
        UserDocumentOwnership.upsert({ user_id: user.id, document_id: drive_file.document.id }, unique_by: %i[user_id document_id])
      end
    end
  end

  def google_drive_client
    @google_drive_client ||= Google::Apis::DriveV2::DriveService.new.tap do |drive|
      drive.authorization = client
    end
  end

  def search_query
    last_sync_at = user.sync_logs.where(task_name: 'Sync::GoogleDocsJob').maximum(:started_at)

    if last_sync_at.present?
      "mimeType = 'application/vnd.google-apps.document' and modifiedTime > '#{last_sync_at.strftime('%Y-%m-%dT%H:%M:%S')}'"
    else
      "mimeType = 'application/vnd.google-apps.document'"
    end
  end

  attr_reader :client, :user
end
