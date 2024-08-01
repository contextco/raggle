# frozen_string_literal: true

class EmbeddingService
  def self.generate(text)
    LLMClients::OpenAi.new(llm: nil).embedding([text])
  end
end
