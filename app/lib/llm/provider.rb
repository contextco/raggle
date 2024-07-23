# frozen_string_literal: true

class LLM::Provider
  include ActiveModel::Model

  attr_accessor :canonical_name,
    :display_name

  def models
    LLM.all!.select { |llm| llm.provider_canonical_name == canonical_name }
  end

  class << self
    def from_string(provider_string)
      by_canonical_name[provider_string]
    end

    def all
      LLM::Info::KNOWN_PROVIDERS.map { |provider| new(provider) }
    end

    private

    def by_canonical_name
      @by_canonical_name ||= all.index_by(&:canonical_name)
    end
  end
end
