# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLM::Validations::Temperature do
  subject(:validator) { described_class.new({ min: 0, max: 100 }) }

  describe '#validate' do
    context 'when temperature is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(temperature: 50) }.not_to raise_error
      end
    end

    context 'when temperature is outside the specified range' do
      it 'raises TemperatureOutsideRange error' do
        expect { validator.validate(temperature: 150) }.to raise_error(LLM::Validations::Temperature::TemperatureOutsideRange)
      end
    end

    context 'when temperature key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::TopP do
  subject(:validator) { described_class.new({ min: 0, max: 1 }) }

  describe '#validate' do
    context 'when top_p is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(top_p: 0.5) }.not_to raise_error
      end
    end

    context 'when top_p is outside the specified range' do
      it 'raises TopPOutsideRange error' do
        expect { validator.validate(top_p: 1.5) }.to raise_error(LLM::Validations::TopP::TopPOutsideRange)
      end
    end

    context 'when top_p key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::TopK do
  subject(:validator) { described_class.new({ min: 0, max: 10 }) }

  describe '#validate' do
    context 'when top_k is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(top_k: 5) }.not_to raise_error
      end
    end

    context 'when top_k parameter value is incorrect' do
      it 'raises error when value outside range' do
        expect { validator.validate(top_k: 15) }.to raise_error(LLM::Validations::TopK::TopKOutsideRange)
      end

      it 'raises error when value not an integer' do
        expect { validator.validate(top_k: 1.5) }.to raise_error(LLM::Validations::TopK::TopKMustHaveIntegerValue)
      end
    end

    context 'when top_k key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::StopSequences do
  subject(:validator) { described_class.new }

  describe '#validate' do
    context 'when stop_sequences is a non-empty array of strings' do
      it 'does not raise an error' do
        expect { validator.validate(stop_sequences: %w[stop1 stop2]) }.not_to raise_error
      end
    end

    context 'when stop_sequences is empty' do
      it 'raises StopSequencesInvalid error' do
        expect { validator.validate(stop_sequences: [123]) }.to raise_error(LLM::Validations::StopSequences::StopSequencesInvalid)
      end
    end

    context 'when stop_sequences key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::MaxTokensToSample do
  subject(:validator) { described_class.new({ min: 0, max: 100 }) }

  describe '#validate' do
    context 'when max_tokens_to_sample is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(max_tokens_to_sample: 50) }.not_to raise_error
      end
    end

    context 'when max_tokens_to_sample is outside the specified range' do
      it 'raises MaxTokensOutsideRange error' do
        expect { validator.validate(max_tokens_to_sample: 150) }.to raise_error(LLM::Validations::MaxTokensToSample::MaxTokensOutsideRange)
      end
    end

    context 'when max_tokens_to_sample key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::CandidateCount do
  subject(:validator) { described_class.new({ min: 0, max: 10 }) }

  describe '#validate' do
    context 'when candidate_count is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(candidate_count: 5) }.not_to raise_error
      end
    end

    context 'when candidate_count is outside the specified range' do
      it 'raises CandidateCountOutsideRange error' do
        expect { validator.validate(candidate_count: 15) }.to raise_error(LLM::Validations::CandidateCount::CandidateCountOutsideRange)
      end
    end

    context 'when candidate_count key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::MaxOutputTokens do
  subject(:validator) { described_class.new({ min: 0, max: 100 }) }

  describe '#validate' do
    context 'when max_output_tokens is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(max_output_tokens: 50) }.not_to raise_error
      end
    end

    context 'when max_output_tokens is outside the specified range' do
      it 'raises MaxOutputTokensOutsideRange error' do
        expect { validator.validate(max_output_tokens: 150) }.to raise_error(LLM::Validations::MaxOutputTokens::MaxOutputTokensOutsideRange)
      end
    end

    context 'when max_output_tokens key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::FrequencyPenalty do
  subject(:validator) { described_class.new(min: 0, max: 1) }

  describe '#validate' do
    context 'when frequency_penalty is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(frequency_penalty: 0.5) }.not_to raise_error
      end
    end

    context 'when frequency_penalty is outside the specified range' do
      it 'raises FrequencyPenaltyOutsideRange error' do
        expect { validator.validate(frequency_penalty: 1.5) }.to raise_error(LLM::Validations::FrequencyPenalty::FrequencyPenaltyOutsideRange)
      end
    end

    context 'when frequency_penalty key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end

RSpec.describe LLM::Validations::PresencePenalty do
  subject(:validator) { described_class.new(min: 0, max: 1) }

  describe '#validate' do
    context 'when presence_penalty is within the specified range' do
      it 'does not raise an error' do
        expect { validator.validate(presence_penalty: 0.5) }.not_to raise_error
      end
    end

    context 'when presence_penalty is outside the specified range' do
      it 'raises PresencePenaltyOutsideRange error' do
        expect { validator.validate(presence_penalty: 1.5) }.to raise_error(LLM::Validations::PresencePenalty::PresencePenaltyOutsideRange)
      end
    end

    context 'when presence_penalty key is not present' do
      it 'returns true without raising an error' do
        expect(validator.validate({})).to be true
      end
    end
  end
end
