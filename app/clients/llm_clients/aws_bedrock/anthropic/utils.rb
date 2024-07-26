# frozen_string_literal: true

module LLMClients
  module AwsBedrock
    module Anthropic
      class Utils
        def request_parameters(messages, model, **kwargs)
          {
            model_id: model,
            body: {
              prompt: append_special_tokens(messages),
              max_tokens_to_sample: kwargs[:max_tokens_to_sample] || 400,
              temperature: kwargs[:temperature],
              top_p: kwargs[:top_p],
              top_k: kwargs[:top_k],
              stop_sequences: kwargs[:stop_sequences]
            }.compact_blank.to_json,
            content_type: 'application/json',
            accept: 'application/json'
          }
        end

        def parse_response(response)
          # TODO: handle correct stop_reason
          LLMClients::Response.new(content: response[:completion].strip, full_json: response, success: true,
                                   stop_reason: :stop)
        end

        private

        ROLE_MAP = {
          'system' => "\n\nHuman",
          'user' => "\n\nHuman",
          'assistant' => "\n\nAssistant"
        }.freeze

        def append_special_tokens(messages)
          prompt = ''
          messages.map do |message|
            prompt += "#{ROLE_MAP[message[:role]]}: #{message[:content]}"
          end
          "#{prompt}#{ROLE_MAP['assistant']}:"
        end
      end
    end
  end
end
