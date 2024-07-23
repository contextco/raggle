# frozen_string_literal: true

module LLMClients::AwsBedrock::Mistral
  class Utils
    def request_parameters(messages, model, **kwargs)
      {
        model_id: model,
        body: {
          prompt: LLMClients::AwsBedrock::Encoder::Chat.add_special_tokens(messages),
          temperature: kwargs[:temperature],
          top_p: kwargs[:top_p],
          top_k: kwargs[:top_k],
          max_tokens: kwargs[:max_output_tokens]
        }.compact_blank.to_json,
        content_type: 'application/json',
        accept: 'application/json'
      }
    end

    def parse_response(response)
      output = response[:outputs].first
      LLMClients::Response.new(content: output[:text].strip, full_json: response, success: true, stop_reason: :stop)
    end
  end
end
