# frozen_string_literal: true

require 'openai'

class LLMClients::OpenAi
  def initialize(llm:)
    @client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY', nil))
    @llm = llm
  end

  def embedding(texts)
    resp = @client.embeddings(
      parameters: {
        input: texts,
        model: 'text-embedding-ada-002'
      }
    )

    resp.dig('data', 0, 'embedding')
  end

  def chat(messages, **kwargs)
    parameters = {
      model: @llm.client_model_identifier,
      messages:,
      temperature: kwargs[:temperature],
      response_format: kwargs[:response_format],
      max_tokens: kwargs[:max_output_tokens],
      top_p: kwargs[:top_p],
      stop: kwargs[:stop_sequences],
      presence_penalty: kwargs[:presence_penalty],
      frequency_penalty: kwargs[:frequency_penalty],
      tools: kwargs[:tools],
      tool_choice: kwargs[:tool_choice],
      seed: ENV['LLM_SEED_VALUE']&.to_i
    }.compact_blank

    resp = @client.chat(parameters:)
    stop_reason = normalised_stop_reason(resp.dig('choices', 0, 'finish_reason'))
    tool_calls = resp.dig('choices', 0, 'message', 'tool_calls')
    LLMClients::Response.new(content: resp.dig('choices', 0, 'message', 'content'), tool_calls:, full_json: resp,
                             success: stop_reason == :stop, stop_reason:)
  rescue Faraday::ClientError => e
    raise LLMClients::RateLimitError, 'OpenAI rate limit exceeded' if e.response[:status] == 429

    error_response(e, :client_error)
  rescue Faraday::ServerError => e
    raise LLMClients::InternalServerError, 'OpenAI server error' if e.response[:status] == 500

    error_response(e, :server_error)
  end

  def chat_streaming(messages, on_message, complete_proc, **kwargs)
    buffer = String.new
    chunks = []

    parameters = {
      model: @llm.client_model_identifier,
      messages:,
      temperature: kwargs[:temperature],
      response_format: kwargs[:response_format],
      max_tokens: kwargs[:max_output_tokens],
      top_p: kwargs[:top_p],
      stop: kwargs[:stop_sequences],
      presence_penalty: kwargs[:presence_penalty],
      frequency_penalty: kwargs[:frequency_penalty],
      stream: stream_proc(buffer, chunks, on_message, complete_proc)
    }.compact_blank

    @client.chat(parameters:)
    stop_reason = normalised_stop_reason(chunks.last&.dig('choices', 0, 'finish_reason'))
    LLMClients::Response.new(content: buffer, full_json: chunks, success: stop_reason == :stop, stop_reason:)
  rescue Faraday::ClientError => e
    raise LLMClients::RateLimitError, 'OpenAI rate limit exceeded' if e.response[:status] == 429

    error_response(e, :client_error)
  rescue Faraday::ServerError => e
    raise LLMClients::InternalServerError, 'OpenAI server error' if e.response[:status] == 500

    error_response(e, :server_error)
  end

  def complete_prompt(prompt, query:)
    p = prompt + "\nUser: #{query}\nAI: "

    resp = @client.completions(
      parameters: {
        model: @llm.client_model_identifier,
        prompt: p,
        temperature: 0.7
      }
    )

    resp.dig('choices', 0, 'text')
  end

  private

  def stream_proc(buffer, chunks, on_message, complete_proc)
    proc do |chunk, _bytesize|
      chunks << chunk
      new_content = chunk.dig('choices', 0, 'delta', 'content')
      finish_reason = chunk.dig('choices', 0, 'finish_reason')

      buffer << new_content unless new_content.nil?
      on_message.call(new_content, buffer) unless new_content.nil?
      complete_proc.call(finish_reason, buffer) if finish_reason.present?
    end
  end

  def normalised_stop_reason(stop_reason)
    return :stop if stop_reason == 'stop'
    return :safety if stop_reason == 'content_filter'
    return :max_tokens if stop_reason == 'length'

    # can also be function_call and null
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
