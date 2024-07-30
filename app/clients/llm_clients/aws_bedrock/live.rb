# frozen_string_literal: true

class LLMClients::AwsBedrock::Live
  def initialize(llm:)
    @client = Aws::BedrockRuntime::Client.new(
      region: 'us-east-1',
      credentials: Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
      )
    )
    @llm = llm
  end

  def chat(messages, **)
    utils = instantiate_provider_helper
    params = utils.request_parameters(messages,
                                      @llm.client_model_identifier,
                                      instruct_only: @llm.instruct_model.present?,
                                      **)
    json_response = model_response(params)
    utils.parse_response(json_response)
  rescue Aws::BedrockRuntime::Errors::ServiceError => e
    if e.context.http_response.status_code >= 400 && e.context.http_response.status_code < 500
      if e.context.http_response.status_code == 429
        raise LLMClients::RateLimitError,
              'AwsBedrock rate limit exceeded'
      end

      error_response(e, :client_error)
    elsif e.context.http_response.status_code >= 500 && e.context.http_response.status_code < 600
      raise LLMClients::InternalServerError, 'AwsBedrock server error' if e.context.http_response.status_code == 500

      error_response(e, :server_error)
    end
  end

  def chat_streaming(messages, on_message_proc, on_complete_proc, **)
    utils = instantiate_provider_helper
    params = utils.request_parameters(messages,
                                      @llm.client_model_identifier,
                                      instruct_only: @llm.instruct_model.present?,
                                      **)
    buf = String.new
    @client.converse_stream(params, &handle_stream(buf, on_message_proc, on_complete_proc))
    LLMClients::Response.new(content: buf, success: true, stop_reason: :stop)
  end

  private

  def handle_stream(buffer, on_message_proc, on_complete_proc)
    proc do |stream|
      stream.on_content_block_delta_event do |chunk|
        value = chunk.delta.value
        buffer << value
        on_message_proc.call(value, buffer)
      end

      stream.on_message_stop_event do |_chunk|
        on_complete_proc.call(buffer, :stop)
      end

      stream.on_internal_server_exception_event do |err|
        on_complete_proc.call(buffer, :server_error)
        raise LLMClients::InternalServerError, err.message
      end
    end
  end

  def model_response(params)
    response = @client.invoke_model(params)
    JSON.parse(response.body.read, { symbolize_names: true })
  end

  def instantiate_provider_helper
    return LLMClients::AwsBedrock::Meta::Utils.new if @llm.provider_canonical_name == :meta
    return LLMClients::AwsBedrock::Anthropic::Utils.new if @llm.provider_canonical_name == :anthropic
    return LLMClients::AwsBedrock::Mistral::Utils.new if @llm.provider_canonical_name == :mistral

    raise "Unknown provider model: #{@llm.provider_canonical_name}"
  end

  def error_response(err, error_type)
    LLMClients::Response.new(
      content: nil,
      full_json: err.context.http_response,
      success: false,
      stop_reason: error_type
    )
  end
end
