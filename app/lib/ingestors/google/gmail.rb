# frozen_string_literal: true

class Ingestors::Google::Gmail
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

  def ingest
    messages = gmail_client.list_user_messages('me')&.messages
    messages&.each(&method(:persist_or_update_message))

    nil
  end

  private

  def persist_or_update_message(message)
    document = Document.find_by(stable_id: message.id, documentable_type: GmailMessage.name)
    return if document&.last_sync_at.present? && document.last_sync_at.to_i > message.internal_date

    response = gmail_client.get_user_message('me', message.id)

    Document.transaction do
      if document.present?
        document.documentable.update_and_rechunk!(response, message)
        UserDocumentOwnership.upsert({ user_id: user.id, document_id: document.id }, unique_by: %i[user_id document_id])
      else
        gmail_message = GmailMessage.create_from_gmail_payload!(response, message)
        UserDocumentOwnership.upsert({ user_id: user.id, document_id: gmail_message.document.id }, unique_by: %i[user_id document_id])
      end
    end
  end

  def gmail_client
    @gmail_client ||= Google::Apis::GmailV1::GmailService.new.tap do |gmail|
      gmail.authorization = client
    end
  end

  attr_reader :client, :user
end
