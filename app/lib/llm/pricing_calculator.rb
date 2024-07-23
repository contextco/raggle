# frozen_string_literal: true

class LLM::PricingCalculator
  def initialize(llm)
    @llm = llm

    raise "No pricing calculator available for #{llm.canonical_name}" unless llm.pricing_calculation_allowed?
  end

  def price_in_cents(content, type: :input)
    unit_count = tokenizer.count(content)

    price_per_thousand_units = case type
                               when :input
                                 input_price
                               when :output
                                 output_price
                               else
                                 raise "Unknown LLM I/O type, must be either input or :output #{type}"
    end

    price_per_thousand_units * unit_count / 1000
  end

  # Normalization factor for converting characters into tokens.
  # OpenAI says that 1 token is ~4 characters:
  # https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them
  CHARACTER_TO_TOKEN_RATIO = 4

  private

  attr_reader :llm

  delegate :tokenizer, to: :llm

  def input_price
    llm.cents_per_thousand_input_tokenization_units
  end

  def output_price
    llm.cents_per_thousand_output_tokenization_units
  end
end
