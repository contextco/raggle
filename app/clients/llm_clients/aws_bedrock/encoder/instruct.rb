# frozen_string_literal: true

class LLMClients::AwsBedrock::Encoder::Instruct
  DELIMITERS = {
    start: '<|begin_of_text|>',
    end: '<|end_of_text|>',
    start_header: '<|start_header_id|>',
    end_header: '<|end_header_id|>',
    end_turn: '<|eot_id|>'
  }.freeze

  def self.add_special_tokens(messages)
    @templatized_message = DELIMITERS[:start]
    messages.each do |message|
      add_role_change_indicators(message[:role])
      @templatized_message += "#{message[:content]}#{DELIMITERS[:end_turn]}"
    end
    add_role_change_indicators('assistant')
  end

  private_class_method def self.add_role_change_indicators(role)
    @templatized_message += "#{DELIMITERS[:start_header]}#{role}#{DELIMITERS[:end_header]}\n\n"
  end
end
