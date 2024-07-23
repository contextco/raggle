# frozen_string_literal: true

class LLMClients::Anthropic
  def initialize(llm:)
    @llm = llm
  end

  def chat(messages, **kwargs)
    config = @llm.config_validator(kwargs).assign_defaults!
    resp = chat_request(payload(messages, **config))
    response = JSON.parse(resp.body)

    stop_reason = translate_stop_reason(response['stop_reason'])
    LLMClients::Response.new(
      content: response.dig('content', 0, 'text'),
      full_json: response,
      success: %i[stop user_provided_stop_sequence_emitted].include?(stop_reason),
      stop_reason:
    )
  rescue Faraday::TimeoutError
    raise LLMClients::TimeoutError, 'Timed out'
  rescue Faraday::ClientError => e
    raise LLMClients::RateLimitError, 'Anthropic rate limit exceeded' if e.response[:status] == 429

    error_response(e, :client_error)
  rescue Faraday::ServerError => e
    raise LLMClients::InternalServerError, 'Anthropic server error' if e.response[:status] == 500

    error_response(e, :server_error)
  end

  private

  def payload(messages, **kwargs)
    {
      # TODO: Claude allows only a single system message :(
      #       so we need to establish via validation somewhere that no other messages are 'system' messages.
      system: messages.first[:role].to_sym == :system ? messages.first[:content] : nil,
      messages: messages.filter { |m| m[:role].to_sym != :system },
      model: @llm.client_model_identifier,
      max_tokens: kwargs[:max_output_tokens],
      temperature: kwargs[:temperature],
      top_p: kwargs[:top_p],
      top_k: kwargs[:top_k]
    }.compact_blank
  end

  def chat_request(payload)
    conn = Faraday.new(url: 'https://api.anthropic.com', request: { timeout: 90 }) do |faraday|
      faraday.request :json
      faraday.use Faraday::Response::RaiseError
    end
    conn.post('/v1/messages') do |request|
      request.headers['anthropic-version'] = '2023-06-01'
      request.headers['x-api-key'] = SecureCredentials.anthropic_api_key
      request.body = payload
    end
  end

  def translate_stop_reason(stop_reason)
    case stop_reason
    when 'end_turn'
      :stop
    when 'max_tokens'
      :max_tokens
    when 'stop_sequence'
      :user_provided_stop_sequence_emitted
    else
      :other
    end
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
