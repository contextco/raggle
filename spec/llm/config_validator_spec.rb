# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLM::ConfigValidator do
  subject(:validator) { described_class.new(validations, config) }

  let(:config) { { temperature: 0.7 } }
  let(:validations) { [LLM::Validations::Temperature.new({ min: 0.0, max: 1.0 })] }

  describe '#validate!' do
    context 'when config is valid' do
      it 'does not raise an error' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when config contains an invalid key' do
      let(:config) { { invalid_key: 'value' } }

      it 'raises an error if config has invalid keys' do
        expect { validator.validate! }.to raise_error(RuntimeError, 'Invalid config keys: invalid_key')
      end
    end

    context 'when config contains an invalid value' do
      let(:config) { { temperature: 1.1 } }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(StandardError)
      end
    end
  end

  describe '#assign_defaults!' do
    context 'when config is empty' do
      let(:config) { {} }

      it 'assigns default values to config' do
        expect(validator.assign_defaults!).to eq({ temperature: 0.7 })
      end
    end

    context 'when config is not empty' do
      let(:config) { { temperature: 0.5 } }

      it 'does not override existing values' do
        expect(validator.assign_defaults!).to eq({ temperature: 0.5 })
      end
    end
  end
end
