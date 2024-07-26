# frozen_string_literal: true

# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/AbcSize

require 'google-cloud-ai_platform'

# TODO: refactor parameters better
class LLMClients::GoogleVertex
  def initialize(llm:)
    @client = Google::Cloud::AIPlatform.prediction_service do |config|
      config.endpoint = 'us-central1-aiplatform.googleapis.com'
    end
    @llm = llm
  end

  def chat(messages, **kwargs)
    prompt, context = prepare_messages(messages)
    request = Google::Cloud::AIPlatform::V1::PredictRequest.new(
      endpoint: "projects/#{ENV.fetch('GOOGLE_CLOUD_PROJECT',
                                      nil)}/locations/us-central1/publishers/google/models/#{@llm.client_model_identifier}",
      instances: [
        {
          struct_value: {
            fields: {
              'context' => { string_value: prompt },
              'messages' => { list_value: {
                values: context
              } }
            }
          }
        }
      ],
      parameters: {
        struct_value: {
          fields: {
            'temperature' => kwargs[:temperature].present? ? Google::Protobuf::Value.new(number_value: kwargs[:temperature]) : nil,
            'topP' => kwargs[:top_p].present? ? Google::Protobuf::Value.new(number_value: kwargs[:top_p]) : nil,
            'topK' => kwargs[:top_k].present? ? Google::Protobuf::Value.new(number_value: kwargs[:top_k]) : nil,
            'candidateCount' => kwargs[:candidate_count].present? ? Google::Protobuf::Value.new(number_value: kwargs[:candidate_count]) : nil,
            'maxOutputTokens' => kwargs[:max_output_tokens].present? ? Google::Protobuf::Value.new(number_value: kwargs[:max_output_tokens]) : nil,
            'stopSequences' => kwargs[:stop_sequences].present? ? prepare_array(kwargs[:stop_sequences]) : nil,
            'frequencyPenalty' => kwargs[:frequency_penalty].present? ? Google::Protobuf::Value.new(number_value: kwargs[:frequency_penalty]) : nil,
            'presencePenalty' => kwargs[:presence_penalty].present? ? Google::Protobuf::Value.new(number_value: kwargs[:presence_penalty]) : nil,
            'logProbs' => kwargs[:log_probs].present? ? Google::Protobuf::Value.new(number_value: kwargs[:log_probs]) : nil,
            'logitBias' => if kwargs[:logit_bias].present?
                             Google::Protobuf::Value.new(list_value: JSON.parse(kwargs[:logit_bias].gsub(
                                                                                  '=>', ':'
                                                                                )))
                           end,
            'seed' => kwargs[:seed].present? ? Google::Protobuf::Value.new(number_value: kwargs[:seed]) : nil
          }.compact_blank
        }
      }
    )

    resp = @client.predict(request)

    # TODO: more intelligent success reporting, always return :stop for now
    LLMClients::Response.new(content: resp['predictions'][0]['struct_value']['candidates'][0]['content'],
                             full_json: resp, success: true, stop_reason: :stop)
  rescue Google::Cloud::Error, Google::Cloud::AIPlatform::V1::PredictionService::Client::ArgumentError => e
    return error_response(e, :other) unless e.respond_to?(:code)

    case e.code
    when GRPC::Core::StatusCodes::UNAVAILABLE, GRPC::Core::StatusCodes::INTERNAL
      if e.code == GRPC::Core::StatusCodes::INTERNAL
        raise LLMClients::InternalServerError,
              'Google Vertex server error'
      end

      error_response(e, :server_error)
    else
      if e.code == GRPC::Core::StatusCodes::RESOURCE_EXHAUSTED
        raise LLMClients::RateLimitError,
              'Google Vertex rate limit exceeded'
      end

      error_response(e, :client_error)
    end
  end

  def complete_prompt(prompt:, query:)
    p = prompt + "\nInput: #{query}\nOutput: "

    request = Google::Cloud::AIPlatform::V1::PredictRequest.new(
      endpoint: "projects/#{ENV.fetch('GOOGLE_CLOUD_PROJECT',
                                      nil)}/locations/us-central1/publishers/google/models/#{@llm.client_model_identifier}",
      instances: [
        {
          struct_value: {
            fields: {
              'prompt' => { string_value: p }
            }
          }
        }
      ],
      parameters: {
        struct_value: {
          fields: {
            'temperature' => Google::Protobuf::Value.new(number_value: 0.7),
            'maxOutputTokens' => Google::Protobuf::Value.new(number_value: 400)
          }
        }
      }
    )

    resp = @client.predict(request)

    s_value = resp['predictions'][0]['struct_value']
    return { output: '', safety_block: true } if s_value['safetyAttributes']['blocked']

    s_value['content']
  end

  private

  def prepare_array(array)
    items = array.map do |item|
      Google::Protobuf::Value.new(string_value: item)
    end
    Google::Protobuf::Value.new(list_value: { values: items })
  end

  def prepare_messages(messages)
    prompt = messages[0][:role] == 'system' ? messages[0][:content] : ''
    remaining_messages = messages[0][:role] == 'system' ? messages[1..] : messages
    context = remaining_messages.map do |message|
      {
        struct_value: {
          fields: {
            'author' => { string_value: message[:role] },
            'content' => { string_value: message[:content] }
          }
        }
      }
    end
    [prompt, context]
  end

  def error_response(err, error_type)
    error = {
      code: err.code,
      message: err.message,
      details: err.details
    }
    LLMClients::Response.new(
      content: nil,
      full_json: error,
      success: false,
      stop_reason: error_type
    )
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/AbcSize
