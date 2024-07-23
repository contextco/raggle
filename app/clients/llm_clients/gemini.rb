# frozen_string_literal: true

require 'faraday'
require 'json'

class LLMClients::Gemini
  def initialize(llm:)
    @authorizer = ::Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', '')),
      scope: 'https://www.googleapis.com/auth/cloud-platform'
    )
    @llm = llm
  end

  def chat(messages, **kwargs)
    url = "https://us-central1-aiplatform.googleapis.com/v1/projects/#{ENV.fetch('GOOGLE_CLOUD_PROJECT',
                                                                                 nil)}/locations/us-central1/publishers/google/models/#{@llm.client_model_identifier}:streamGenerateContent"
    payload = {
      contents: prepare_messages(messages),
      safetySettings: {},
      generationConfig: {
        temperature: kwargs[:temperature],
        topP: kwargs[:top_p],
        topK: kwargs[:top_k],
        candidateCount: 1,
        maxOutputTokens: kwargs[:max_output_tokens],
        stopSequences: kwargs[:stop_sequences]
      }.compact_blank
    }
    response = stream_generate_content(url, payload)
    consolidate_response(JSON.parse(response.body))
  rescue Faraday::ClientError => e
    raise LLMClients::RateLimitError, 'Gemini rate limit exceeded' if e.response[:status] == 429

    error_response(e, :client_error)
  rescue Faraday::ServerError => e
    raise LLMClients::InternalServerError, 'Gemini server error' if e.response[:status] == 500

    error_response(e, :server_error)
  end

  private

  def prepare_messages(messages)
    return if messages.nil?

    messages[0][:role] = 'user' if messages.dig(0, :role) == 'system'
    messages = merge_consecutive_messages(messages)
    messages.map do |message|
      {
        parts: [
          {
            text: message[:content]
          }
        ],
        role: message[:role] == 'assistant' ? 'model' : message[:role]
      }
    end
  end

  def merge_consecutive_messages(messages)
    messages.chunk_while { |msg1, msg2| msg1[:role] == msg2[:role] }.each do |group|
      group.first[:content] += "\n\n#{group[1..].pluck(:content).join("\n\n")}"
      group[1..].each { |msg| msg[:content] = nil }
    end
    messages.reject { |message| message[:content].nil? }
  end

  def stream_generate_content(url, payload)
    conn = Faraday.new(url:)
    conn.post('') do |request|
      request.headers['Content-Type'] = 'application/json'
      request.headers['Authorization'] = "Bearer #{@authorizer.fetch_access_token!['access_token']}"
      request.body = payload.to_json
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def consolidate_response(response_data)
    return LLMClients::Response.new(success: false, stop_reason: :other) if response_data.nil?

    response = ''
    stop_reason = nil
    response_data.each do |item|
      candidates = item['candidates']
      next if candidates.nil?

      # should always be only one candidate as candidateCount can only be 1
      candidates.each do |candidate|
        stop_reason = candidate['finishReason'] if stop_reason.nil?

        content = candidate['content']
        parts = content['parts']
        next if parts.nil? # can happen if finishReason is safety

        parts.each do |part|
          response += part['text'] if part.key?('text')
        end
      end
    end
    stop_reason = normalised_stop_reason(stop_reason)
    # fail unless llm hits a stop token
    LLMClients::Response.new(content: response, full_json: response_data, success: success?(stop_reason), stop_reason:)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def success?(stop_reason)
    # documentation for this quite poor, but appears that there is not always a finishReason.
    # for now if there is not finishReason, we assume it was a success
    stop_reason.nil? || stop_reason == :stop
  end

  def normalised_stop_reason(stop_reason)
    return :stop if stop_reason == 'STOP'
    return :safety if stop_reason == 'SAFETY'
    return :max_tokens if stop_reason == 'MAX_TOKENS'
    return :recitation if stop_reason == 'RECITATION'

    # can also be UNSPECIFIED or OTHER
    :other
  end

  def error_response(err, error_type)
    LLMClients::Response.new(
      content: nil,
      full_json: err.response,
      success: false,
      stop_reason: error_type
    )
  end
end
