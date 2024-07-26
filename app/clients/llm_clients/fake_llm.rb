# frozen_string_literal: true

module LLMClients
  class FakeLLM
    def initialize(llm:)
      @llm = llm
    end

    def embedding(_texts)
      Array.new(1536) { rand(-1.0..1.0) }
    end

    def chat(_messages, **)
      LLMClients::Response.new(content: FFaker::Lorem.sentence, full_json: {}, success: true, stop_reason: :stop)
    end

    def complete_prompt(**)
      FFaker::Lorem.sentence
    end

    def chat_streaming(_messages, stream_proc, complete_proc, **)
      buffer = String.new

      rand(10..100).times do
        sleep(rand(0.1..0.2)) unless Rails.env.test?
        word = "#{FFaker::Lorem.word} "
        buffer << word
        stream_proc.call(word)
      end

      complete_proc.call

      LLMClients::Response.new(content: buffer, full_json: {}, success: true, stop_reason: :stop)
    end
  end
end
