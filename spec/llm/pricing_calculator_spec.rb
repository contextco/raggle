# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLM::PricingCalculator do
  describe '#price_in_cents' do
    LLM.all!.filter(&:pricing_calculation_allowed?).each do |llm|
      it 'calculates the price for input tokenization' do
        expect(llm.pricing_calculator.price_in_cents('This is a test string')).to be_a(BigDecimal)
      end

      it 'calculates the price for output tokenization' do
        expect(llm.pricing_calculator.price_in_cents('This is a test string', type: :output)).to be_a(BigDecimal)
      end

      it 'raises an error for unknown tokenization type' do
        expect { llm.pricing_calculator.price_in_cents('This is a test string', type: :unknown) }
          .to raise_error(RuntimeError, 'Unknown LLM I/O type, must be either input or :output unknown')
      end
    end
  end
end
