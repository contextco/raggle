# frozen_string_literal: true

module LLM
  class Summary
    class << self
      def generate(model_name)
        model = LLM.from_string!(model_name)

        summary(config_with_summary_fields(model))
      end

      private

      def prompt
        Prompt.new(:summary_from_model_config).render_to_string
      end

      def summary(summary_config)
        client = LLM.from_string!('gpt-3.5-turbo')&.client
        input = <<~TEXT
          <INPUT>
          #{summary_config.to_json}
          <END INPUT>
        TEXT

        client.chat(
          [
            {
              role: 'system',
              content: prompt
            },
            {
              role: 'user',
              content: input
            }
          ],
          temperature: 0.1
        ).content
      end

      def config_with_summary_fields(model_config)
        {
          model: model_config.canonical_name,
          display_name: model_config.display_name,
          provider_canonical_name: model_config.provider_canonical_name,
          context_window_tokens: model_config.context_window_tokens,
          cents_per_thousand_input_tokenization_units: model_config.cents_per_thousand_input_tokenization_units,
          cents_per_thousand_output_tokenization_units: model_config.cents_per_thousand_output_tokenization_units,
          release_date: model_config.release_date,
          benchmarks: model_config.benchmarks&.map { |benchmark| benchmark.slice(:name, :score, :caveat) }
        }.compact_blank
      end
    end
  end
end
