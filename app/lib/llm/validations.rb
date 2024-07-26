# frozen_string_literal: true

module LLM::Validations
  class RangeValidator
    include ActiveModel::Validations

    attr_reader :attr_value

    def initialize(range, default = nil)
      @range = range
      @default = default
    end

    def default_value
      @default
    end

    def validate?(attr_value)
      self.attr_value = attr_value
      valid?
    end

    private

    attr_writer :attr_value

    validates :attr_value, numericality: { greater_than_or_equal_to: lambda { |obj|
                                                                       obj.instance_variable_get(:@range)[:min]
                                                                     }, less_than_or_equal_to: lambda { |obj|
                                                                                                 obj.instance_variable_get(:@range)[:max]
                                                                                               } }
  end

  class Temperature < RangeValidator
    attr_accessor :c_key, :range

    TemperatureOutsideRange = Class.new(StandardError)

    def initialize(range, default: 0.7)
      super(range, default)
      @c_key = :temperature
    end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(TemperatureOutsideRange)
    end
  end

  class TopP < RangeValidator
    attr_accessor :c_key, :range

    TopPOutsideRange = Class.new(StandardError)

    def initialize(range, default: 1.0)
      super(range, default)
      @c_key = :top_p
    end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(TopPOutsideRange)
    end
  end

  class TopK < RangeValidator
    attr_accessor :c_key, :range

    TopKOutsideRange = Class.new(StandardError)
    TopKMustHaveIntegerValue = Class.new(StandardError)

    def initialize(range, default: nil)
      super(range, default)
      @c_key = :top_k
    end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      raise(TopKMustHaveIntegerValue) unless model_config[@c_key].is_a?(Integer)

      validate?(model_config[@c_key]) ? true : raise(TopKOutsideRange)
    end
  end

  class StopSequences
    attr_accessor :c_key

    StopSequencesInvalid = Class.new(StandardError)

    def initialize
      @c_key = :stop_sequences
    end

    def default_value; end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      valid_stop_sequences?(model_config[@c_key]) ? true : raise(StopSequencesInvalid)
    end

    private

    def valid_stop_sequences?(value)
      return true if value.blank?
      return false unless value.is_a?(Array) && value.all? { |seq| seq.is_a?(String) }

      true
    end
  end

  class MaxTokensToSample < RangeValidator
    attr_accessor :c_key, :range

    MaxTokensOutsideRange = Class.new(StandardError)

    def initialize(range, default: 400)
      super(range, default)
      @c_key = :max_tokens_to_sample
    end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(MaxTokensOutsideRange)
    end
  end

  class CandidateCount < RangeValidator
    attr_accessor :c_key, :range

    CandidateCountOutsideRange = Class.new(StandardError)

    def initialize(range, default: 1)
      super(range, default)
      @c_key = :candidate_count
    end

    def validate(model_config)
      return true unless model_config.key?(:candidate_count)

      validate?(model_config[@c_key]) && model_config[@c_key].is_a?(Integer) ? true : raise(CandidateCountOutsideRange)
    end
  end

  class MaxOutputTokens < RangeValidator
    attr_accessor :c_key, :range

    MaxOutputTokensOutsideRange = Class.new(StandardError)

    def initialize(range, default: 512)
      super(range, default)
      @c_key = :max_output_tokens
    end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(MaxOutputTokensOutsideRange)
    end
  end

  class FrequencyPenalty < RangeValidator
    attr_accessor :c_key, :range

    FrequencyPenaltyOutsideRange = Class.new(StandardError)

    def initialize(range)
      super
      @c_key = :frequency_penalty
    end

    def default_value; end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(FrequencyPenaltyOutsideRange)
    end
  end

  class PresencePenalty < RangeValidator
    attr_accessor :c_key, :range

    PresencePenaltyOutsideRange = Class.new(StandardError)
    def initialize(range)
      super
      @c_key = :presence_penalty
    end

    def default_value; end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(PresencePenaltyOutsideRange)
    end
  end

  class LogProbs < RangeValidator
    attr_accessor :c_key, :range

    LogProbsOutsideRange = Class.new(StandardError)

    def initialize(range)
      super
      @c_key = :log_probs
    end

    def default_value; end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      validate?(model_config[@c_key]) ? true : raise(LogProbsOutsideRange)
    end
  end

  class LogitBias
    attr_accessor :c_key

    LogitBiasInvalid = Class.new(StandardError)

    def initialize
      @c_key = :logit_bias
    end

    def default_value; end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      model_config[@c_key].is_a?(String) ? true : raise(LogitBiasInvalid)
    end
  end

  class Seed
    attr_accessor :c_key

    SeedInvalid = Class.new(StandardError)

    def initialize
      @c_key = :seed
    end

    def default_value; end

    def validate(model_config)
      return true unless model_config.key?(@c_key)

      model_config[@c_key].is_a?(Integer) ? true : raise(SeedInvalid)
    end
  end
end
