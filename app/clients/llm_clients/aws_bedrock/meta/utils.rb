# frozen_string_literal: true

class LLMClients::AwsBedrock::Meta::Utils
  def request_parameters(messages, model, instruct_only:, **kwargs)
    {
      model_id: model,
      body: {
        prompt: encoder(instruct_only).add_special_tokens(messages),
        temperature: kwargs[:temperature],
        top_p: kwargs[:top_p],
        max_gen_len: kwargs[:max_output_tokens]
      }.compact_blank.to_json,
      content_type: 'application/json',
      accept: 'application/json'
    }
  end

  def parse_response(response)
    # TODO: handle correct stop_reason
    LLMClients::Response.new(content: response[:generation].strip, full_json: response, success: true,
                             stop_reason: :stop)
  end

  def encoder(instruct_only)
    instruct_only ? LLMClients::AwsBedrock::Encoder::Instruct : LLMClients::AwsBedrock::Encoder::Chat
  end
end
