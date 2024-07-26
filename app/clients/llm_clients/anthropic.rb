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

  def chat_streaming(messages, on_message_proc, on_complete_proc, **kwargs)
    config = @llm.config_validator(kwargs).assign_defaults!

    buffer = String.new
    chunks = []
    results = {}

    nested_on_complete_proc = lambda { |finish_reason, buffer|
      on_complete_proc.call(finish_reason, buffer)
      results[:finish_reason] = finish_reason
    }

    config[:stream] = on_data_proc(buffer, chunks, on_message_proc:, on_complete_proc: nested_on_complete_proc)
    chat_request(payload(messages, **config))

    stop_reason = translate_stop_reason(results[:finish_reason])
    LLMClients::Response.new(
      content: buffer,
      full_json: chunks,
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
      system: combined_system_messages(messages),
      messages: messages.filter { |m| m[:role].to_sym != :system },
      model: @llm.client_model_identifier,
      max_tokens: kwargs[:max_output_tokens],
      temperature: kwargs[:temperature],
      top_p: kwargs[:top_p],
      top_k: kwargs[:top_k],
      stream: kwargs[:stream]
    }.compact_blank
  end

  def on_data_proc(buffer, chunks, on_message_proc:, on_complete_proc:)
    -> { handle_event_stream(buffer, chunks, on_message_proc:, on_complete_proc:) }
  end

  def chat_request(payload)
    conn = Faraday.new(url: 'https://api.anthropic.com', request: { timeout: 90 }) do |faraday|
      faraday.request :json
      faraday.use Faraday::Response::RaiseError
    end
    request_payload = payload.dup

    conn.post('/v1/messages') do |request|
      request.headers['anthropic-version'] = '2023-06-01'
      request.headers['x-api-key'] = ENV.fetch('ANTHROPIC_API_KEY', nil)

      if request_payload[:stream].respond_to?(:call)
        request.options.on_data = request_payload[:stream].call
        request_payload[:stream] = true
      elsif request_payload[:stream]
        raise ArgumentError, 'stream must be a proc'
      end

      request.body = request_payload
    end
  end

  def handle_event_stream(buffer, chunks, on_message_proc:, on_complete_proc:)
    each_json_chunk do |type, chunk|
      chunks << chunk
      case type
      when 'content_block_delta'
        new_content = chunk.dig('delta', 'text')
        buffer << new_content
        on_message_proc.call(new_content, buffer)
      when 'message_delta'
        finish_reason = chunk.dig('delta', 'stop_reason')
        on_complete_proc.call(finish_reason, buffer)
      else next
      end
    end
  end

  def each_json_chunk
    parser = EventStreamParser::Parser.new

    proc do |chunk, _bytes, env|
      if env && env.status != 200
        raise_error = Faraday::Response::RaiseError.new
        raise_error.on_complete(env.merge(body: try_parse_json(chunk)))
      end

      parser.feed(chunk) do |type, data|
        yield(type, JSON.parse(data))
      end
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

  def try_parse_json(maybe_json)
    JSON.parse(maybe_json)
  rescue JSON::ParserError
    maybe_json
  end

  def combined_system_messages(messages)
    messages.filter { |m| m[:role].to_sym == :system }.map { |m| m[:content] }.join('\n\n')
  end
end
