# frozen_string_literal: true

class LLM
  include ActiveModel::Model
  include ActiveModel::Attributes

  class GenerationNotAllowed < StandardError; end

  def client
    raise GenerationNotAllowed unless generation_allowed?

    return LLMClients::FakeLLM.new(llm: self) unless use_live_llm?

    client_class.new(llm: self)
  end

  def client_model_identifier
    return client_alias if client_alias.present?

    canonical_name
  end

  def generation_allowed?
    client_class.present?
  end

  def provider
    LLM::Provider.from_string(provider_canonical_name)
  end

  def image_path
    "#{provider_canonical_name}.png"
  end

  def config_validator(config)
    LLM::ConfigValidator.new(config_validation, config)
  end

  def accessible?(team)
    return false if premium_model.present? && !team&.premium_models_enabled?

    true
  end

  def pricing_calculation_allowed?
    [
      cents_per_thousand_input_tokenization_units.present?,
      cents_per_thousand_output_tokenization_units.present?,
      tokenization_allowed?
    ].all?
  end

  def tokenization_allowed?
    [tokenization_unit, tiktoken_model].all?(&:present?)
  end

  def tokenizer
    return nil unless tokenization_allowed?

    LLM::Tokenizer.new(self)
  end

  def pricing_calculator
    return nil unless pricing_calculation_allowed?

    LLM::PricingCalculator.new(self)
  end

  def streaming_allowed?
    supports_streaming.present?
  end

  def dollars_per_million_input_tokenization_units
    cents_per_thousand_input_tokenization_units * 10
  end

  def dollars_per_million_output_tokenization_units
    cents_per_thousand_output_tokenization_units * 10
  end

  def maximum_output_tokens
    config_validation&.find { |cv| cv.c_key == :max_output_tokens }&.range&.dig(:max)
  end

  attr_accessor :canonical_name,
                :client_alias,
                :url_slug,
                :display_name,
                :provider_canonical_name,
                :context_window_tokens,
                :client_class,
                :config_validation,
                :tokenization_unit,
                :tiktoken_model,
                :supports_streaming,
                :premium_model,
                :instruct_model

  attribute :cents_per_thousand_input_tokenization_units, :decimal
  attribute :cents_per_thousand_output_tokenization_units, :decimal
  attribute :release_date, :date

  private

  def use_live_llm?
    Rails.configuration.use_live_llm
  end

  class << self
    def all(team:)
      # TODO: change this so that it only returns models that are accessible to the team
      filtered_models_for_team(team:)
    end

    def all!
      known_models
    end

    def from_string(model_string, team:)
      raise ArgumentError, 'Team is required to use LLM.from_string' if team.nil?

      filtered_models_for_team(team:).find { |model| model.canonical_name == model_string }
    end

    def from_string!(model_string)
      known_models.find { |model| model.canonical_name == model_string }
    end

    def from_url_slug!(url_slug)
      known_models.find { |model| model.url_slug == url_slug }
    end

    private

    def filtered_models_for_team(*)
      known_models
    end

    def known_models
      @known_models ||= LLM::Info::KNOWN_MODELS.map { |model| new(model) }
    end
  end
end
