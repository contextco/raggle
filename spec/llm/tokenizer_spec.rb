# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLM::Tokenizer do
  describe '#count' do
    LLM.all!.filter(&:tokenization_allowed?).each do |llm|
      it "can tokenize a string for #{llm.canonical_name}" do
        expect(llm.tokenizer.count('This is a test string')).to be_a(Integer)
      end

      it "can tokenize an empty string for #{llm.canonical_name}" do
        expect(llm.tokenizer.count('')).to eq(0)
      end
    end
  end
end
