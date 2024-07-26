# frozen_string_literal: true

module LLM
  class ConfigValidator
    def initialize(validations, config)
      @validations = validations
      @config = config
    end

    def validate!
      validate_config_semantics
      validate_extra_keys

      config.compact_blank
    end

    def assign_defaults!
      validations.each do |instance|
        if config[instance.c_key].blank? && instance.default_value.present?
          config[instance.c_key] =
            instance.default_value
        end
      end

      config
    end

    def allowed_keys
      @allowed_keys ||= validations.to_set(&:c_key)
    end

    attr_reader :validations, :config

    private

    def validate_config_semantics
      errors = []
      validations.each do |instance|
        instance.validate(config.transform_keys(&:to_sym))
      rescue StandardError => e
        errors << e.message
      end
      raise errors.join("\n") unless errors.empty?
    end

    def validate_extra_keys
      extra_keys = config.keys.map(&:to_sym) - allowed_keys.to_a
      raise "Invalid config keys: #{extra_keys.join(', ')}" unless extra_keys.empty?
    end
  end
end
