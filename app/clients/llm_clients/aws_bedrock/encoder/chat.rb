# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity
module LLMClients
  module AwsBedrock
    module Encoder
      class Chat
        ##
        # BOS and EOS indicate the start and end of a dialogue.
        # B_SYS and E_SYS the start and end of a system message. System prompt is wrapped within the first [INST] and [/INST] tags.
        # [INST] and [/INST] wrap everything that was provided to the assistant.
        # source: https://github.com/facebookresearch/llama-recipes/blob/main/src/llama_recipes/inference/chat_utils.py
        # source: https://huggingface.co/blog/llama2#how-to-prompt-llama-2
        DELIMITERS = {
          system: { start: "<<SYS>>\n", end: "\n<</SYS>>\n\n" },
          user: { start: '[INST]', end: '[/INST]' },
          statement: { start: "<s>\n", end: "\n</s>\n" }
        }.freeze

        def self.add_special_tokens(messages)
          formatted_messages = DELIMITERS[:statement][:start]
          prev_sender = nil
          skip_itr = false
          messages.each_with_index do |message, index|
            if skip_itr
              skip_itr = false
              next
            end
            formatted_messages += role_change_indicators(prev_sender, message[:role])
            formatted_message, skip_itr = process_message(message, index, messages)
            formatted_messages += formatted_message
            prev_sender = message[:role] == 'system' ? 'user' : message[:role]
          end
          formatted_messages + (prev_sender == 'user' ? " #{DELIMITERS[:user][:end]}" : " #{DELIMITERS[:statement][:end]}")
        end

        private_class_method def self.process_message(message, index, messages)
          case message[:role]
          when 'system'
            if index < messages.length - 1 && messages[index + 1][:role] == 'user'
              [
                "#{DELIMITERS[:system][:start]}#{message[:content]}#{DELIMITERS[:system][:end]}#{messages[index + 1][:content]}", true
              ]
            else
              ["#{DELIMITERS[:system][:start]}#{message[:content]}#{DELIMITERS[:system][:end]}", false]
            end
          else
            [message[:content].to_s.strip, false]
          end
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        private_class_method def self.role_change_indicators(prev_sender, current_sender)
          return "#{DELIMITERS[:user][:start]} " if prev_sender.nil? && %w[user system].include?(current_sender)
          return "#{DELIMITERS[:user][:start]} #{DELIMITERS[:user][:end]} " if prev_sender.nil?

          text = ''
          if prev_sender != current_sender
            if prev_sender == 'user' && current_sender != 'system'
              text += " #{DELIMITERS[:user][:end]} "
            elsif prev_sender == 'assistant' && current_sender == 'system'
              text += "#{DELIMITERS[:statement][:end]}#{DELIMITERS[:statement][:start]} #{DELIMITERS[:user][:start]} "
            elsif prev_sender == 'assistant'
              text += "#{DELIMITERS[:statement][:end]}#{DELIMITERS[:statement][:start]}"
            end

            text += " #{DELIMITERS[:user][:start]} " if current_sender == 'user'
          end
          text
        end
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity
