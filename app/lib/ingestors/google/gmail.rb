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

  REQUIRED_SCOPE = 'https://www.googleapis.com/auth/gmail.readonly'

  def ingest
    q = search_query
    page_token = nil

    loop do
      result = gmail_client.list_user_messages(
        'me',
        include_spam_trash: false,
        q:,
        max_results: 100,
        page_token:
      )

      messages = result&.messages || []
      messages.each(&method(:persist_or_update_message))

      page_token = result&.next_page_token
      break unless page_token
    end

    nil
  end

  private

  def persist_or_update_message(message)
    document = Document.find_by(stable_id: message.id, documentable_type: GmailMessage.name)
    response = gmail_client.get_user_message('me', message.id, format: 'full')

    return if document&.last_sync_at.present? && document.last_sync_at.to_i > response.internal_date / 1000

    headers = extract_headers(response&.payload&.headers)
    body = extract_body(response)
    return if body.blank?

    Document.transaction do
      if document.present?
        document.documentable.update_and_rechunk!(filtered_message(response), body:, headers:)
        UserDocumentOwnership.upsert({ user_id: user.id, document_id: document.id }, unique_by: %i[user_id document_id])
      else
        gmail_message = GmailMessage.create_from_user_message!(filtered_message(response), body:, headers:)
        UserDocumentOwnership.upsert({ user_id: user.id, document_id: gmail_message.document.id }, unique_by: %i[user_id document_id])
      end
    end
  end

  def gmail_client
    @gmail_client ||= Google::Apis::GmailV1::GmailService.new.tap do |gmail|
      gmail.authorization = client
    end
  end

  def extract_headers(headers)
    return {} unless headers

    headers.each_with_object({}) { |header, hash| hash[header.name.downcase] = header.value }.with_indifferent_access
  end

  def search_query
    latest_received_at = user.documents
                             .joins("INNER JOIN gmail_messages ON documents.documentable_id = gmail_messages.id AND documents.documentable_type = 'GmailMessage'")
                             .maximum('gmail_messages.received_at')
    if latest_received_at
      "in:anywhere after:#{(latest_received_at - 1.day).strftime('%Y/%m/%d')}"
    else
      'in:anywhere'
    end
  end

  def filtered_message(payload)
    payload.to_h.except(:raw, :payload)
  end

  def extract_body(response)
    part = part_matching_mime_type(response, 'text/plain')
    return part.body.data if part.present?

    part = part_matching_mime_type(response, 'text/html')
    return html_scrub(part.body.data) if part.present?

    html_scrub(response&.payload&.body&.data)
  end

  def html_scrub(html)
    Loofah.fragment(html).scrub!(:prune).to_text
  end

  def part_matching_mime_type(response, mime_type)
    response&.payload&.parts&.find { |part| part.mime_type == mime_type }
  end

  attr_reader :client, :user
end
