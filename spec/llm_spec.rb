# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLM do
  describe '.all' do
    let(:team) { create(:team) }

    it 'returns all known models' do
      expect(described_class.all(team:).length).to eq LLM::Info::KNOWN_MODELS.length
    end

    context 'when gemini_ultra is disabled' do
      it 'excludes gemini-ultra' do
        expect(described_class.all(team:).map(&:canonical_name)).not_to include('gemini-ultra')
      end
    end
  end

  describe '.all!' do
    it 'returns all known models' do
      expect(described_class.all!.length).to eq LLM::Info::KNOWN_MODELS.length
    end
  end

  describe '.from_string' do
    let(:team) { create(:team) }

    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:llm) { described_class.from_string(model[:canonical_name], team:) }

        it 'returns a model instance for a valid model string' do
          expect(llm).to be_a described_class
        end

        %i[
          canonical_name
          display_name
          provider
          context_window_tokens
        ].each do |attribute|
          it "sets the required field \"#{attribute}\"" do
            expect(llm.send(attribute)).to be_present
          end
        end
      end
    end

    it 'returns nil for an invalid model string' do
      expect(described_class.from_string('invalid', team:)).to be_nil
    end
  end

  describe '#client_model_identifier' do
    let(:team) { create(:team) }

    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:llm) { described_class.from_string(model[:canonical_name], team:).client_model_identifier }

        it { is_expected.to be_present }

        it { is_expected.to eq model[:canonical_name] } if model[:client_alias].blank?
        it { is_expected.to eq model[:client_alias] } if model[:client_alias].present?
      end
    end
  end

  describe '#client' do
    let(:team) { create(:team) }

    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:client) { llm.client }

        let(:llm) { described_class.from_string(model[:canonical_name], team:) }

        it { is_expected.to be_present if llm.generation_allowed? }

        it 'has a valid client class' do
          expect(Module.const_get(model[:client_class].to_s)).to be_present if llm.generation_allowed?
        end

        it 'raises an error if generation is not allowed' do
          expect { client }.to raise_error LLM::GenerationNotAllowed unless llm.generation_allowed?
        end
      end
    end
  end

  describe '#generation_possible?' do
    let(:team) { create(:team) }

    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:llm) { described_class.from_string(model[:canonical_name], team:).generation_allowed? }

        it { is_expected.to eq model[:client_class].present? }
      end
    end
  end

  describe '#image_path' do
    let(:team) { create(:team) }

    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:llm) { described_class.from_string(model[:canonical_name], team:).image_path }

        it { is_expected.to eq "#{model[:provider_canonical_name]}.png" }

        it "returns a valid image path for #{model[:provider_canonical_name]}" do
          expect(Rails.root.join('app', 'assets', 'images', "#{model[:provider_canonical_name]}.png").exist?).to be true
        end
      end
    end
  end

  describe '#tokenization_allowed?' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:llm) { described_class.from_string!(model[:canonical_name]).tokenization_allowed? }

        it { is_expected.to eq model[:tokenization_unit].present? && model[:tiktoken_model].present? }
      end
    end
  end

  describe '#tokenizer' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:tokenizer) { llm.tokenizer }

        let(:llm) { described_class.from_string!(model[:canonical_name]) }

        it { is_expected.to be_a LLM::Tokenizer if llm.tokenization_allowed? }
      end
    end
  end

  describe '#pricing_calculation_allowed?' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:pricing_allowed) { llm.pricing_calculation_allowed? }

        let(:llm) { described_class.from_string!(model[:canonical_name]) }

        it { is_expected.to be_truthy if model[:cents_per_thousand_input_tokenization_units].present? && model[:cents_per_thousand_output_tokenization_units].present? && llm.tokenization_allowed? }
        it { is_expected.to be_falsey if model[:cents_per_thousand_input_tokenization_units].blank? || model[:cents_per_thousand_output_tokenization_units].blank? || !llm.tokenization_allowed? }
      end
    end
  end

  describe '#pricing_calculator' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:pricing_calculator) { llm.pricing_calculator }

        let(:llm) { described_class.from_string!(model[:canonical_name]) }

        it { is_expected.to be_a LLM::PricingCalculator if llm.pricing_calculation_allowed? }
        it { is_expected.to be_nil unless llm.pricing_calculation_allowed? }
      end
    end
  end

  describe '#streaming_allowed?' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:streaming_allowed) { llm.streaming_allowed? }

        let(:llm) { described_class.from_string!(model[:canonical_name]) }

        it { is_expected.to be_truthy if model[:supports_streaming].present? }
        it { is_expected.to be_falsey if model[:supports_streaming].blank? }

        it { is_expected.to be_falsey if llm.generation_allowed? && !llm.client.respond_to?(:chat_streaming) }
      end
    end
  end

  describe '#release_date' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:release_date) { llm.release_date }

        let(:llm) { described_class.from_string!(model[:canonical_name]) }

        it { is_expected.to be_a(Date) if model[:release_date].present? }
        it { is_expected.to be_nil if model[:release_date].blank? }
      end
    end
  end

  describe '#tokenization_unit' do
    LLM::Info::KNOWN_MODELS.each do |model|
      context "when the model is #{model[:canonical_name]}" do
        subject(:tokenization_unit) { llm.tokenization_unit }

        let(:llm) { described_class.from_string!(model[:canonical_name]) }

        it { is_expected.to be_present }
        it { is_expected.to eq model[:tokenization_unit] }
      end
    end
  end
end
