# frozen_string_literal: true

module LLM
  class Tokenizer
    def initialize(llm)
      @llm = llm

      raise "No tokenizer available for #{llm.canonical_name}" unless llm.tokenization_allowed?
    end

    def count(message)
      case llm.tokenization_unit
      when :tokens
        count_tokens(message)
      when :characters
        return 0 if message.nil?

        message.length
      else
        raise "Unknown tokenization unit: #{llm.tokenization_unit}"
      end
    end

    private

    def count_tokens(message)
      tiktoken_encoder(@llm.tiktoken_model).encode(message || '').length
    end

    def tiktoken_encoder(tiktoken_model)
      Tiktoken.encoding_for_model(tiktoken_model)
    end

    attr_reader :llm
  end
end
