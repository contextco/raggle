# frozen_string_literal: true

module LLMClients
  # we should extend this struct as more fields become necessary and attempt to unify across all clients
  Response = Struct.new(:content, :tool_calls, :full_json, :success, :stop_reason)
  RateLimitError = Class.new(StandardError)
  InternalServerError = Class.new(StandardError)
  TimeoutError = Class.new(StandardError)

  def self.build_tools(name:, description:, parameters:, required:)
    [
      {
        type: 'function',
        function: {
          name:,
          description:,
          parameters: {
            type: 'object',
            properties: parameters,
            required:
          }
        }
      }
    ]
  end
end
