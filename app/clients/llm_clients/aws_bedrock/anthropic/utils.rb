# frozen_string_literal: true

class LLMClients::AwsBedrock::Anthropic::Utils
  def request_parameters(messages, model, **_kwargs)
    {
      model_id: model,
      system: system_prompt_from_messages(messages),
      messages: conversation_messages(messages)
    }
  end

  def parse_response(response)
    # TODO: handle correct stop_reason
    LLMClients::Response.new(content: response[:completion].strip, full_json: response, success: true,
                             stop_reason: :stop)
  end

  def parse_response_stream(response, _on_message_proc, _on_complete_proc)
    LLMClients::Response.new(content: response[:completion].strip, full_json: response, success: true,
                             stop_reason: :stop)
  end

  private

  ROLE_MAP = {
    'system' => "\n\nHuman",
    'user' => "\n\nHuman",
    'assistant' => "\n\nAssistant"
  }.freeze

  def system_prompt_from_messages(messages)
    prompt = ''
    messages.select { |m| m[:role].to_sym == :system }.map do |message|
      prompt += "#{ROLE_MAP[message[:role]]}: #{message[:content]}"
    end

    return nil if prompt.empty?

    [{ text: prompt }]
  end

  def conversation_messages(messages)
    messages = messages.reject { |m| m[:role].to_sym == :system }
    messages.map do |message|
      { role: message[:role], content: [{ text: message[:content] }] }
    end
  end

  def append_special_tokens(messages)
    prompt = ''
    messages.map do |message|
      prompt += "#{ROLE_MAP[message[:role]]}: #{message[:content]}"
    end
    "#{prompt}#{ROLE_MAP['assistant']}:"
  end
end
