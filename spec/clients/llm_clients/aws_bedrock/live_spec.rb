# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLMClients::AwsBedrock::Live do
  let(:llm) { LLM.from_string!('claude-3-haiku-20240307') }
  subject(:client) { described_class.new(llm:) }
  let(:messages) do
    [
      { role: 'system', content: 'Hello' },
      { role: 'user', content: 'Hi' }
    ]
  end

  describe '#chat_streaming' do
    around(:each) do |example|
      VCR.use_cassette('llm_clients/bedrock/streaming', match_requests_on: %i[method uri body]) do
        example.run
      end
    end

    subject(:chat_streaming) { client.chat_streaming(messages, ->(_, _) {}, ->(_, _) {}) }

    it 'calls the correct methods' do
      expect(chat_streaming).to be_present
    end

    it 'is successful' do
      expect(chat_streaming.success).to be(true)
    end

    it 'has the correct stop reason' do
      expect(chat_streaming.stop_reason).to eq(:stop)
    end

    it 'calls the on_message callbacks correctly' do
      buf = String.new
      on_message = lambda do |new_content, buffer|
        buf << new_content
        expect(buf).to eq(buffer)
      end

      client.chat_streaming(messages, on_message, ->(_, _) {})
    end

    it 'calls the on_complete callbacks correctly' do
      on_complete = lambda do |buffer, stop_reason|
        expect(buffer).to be_present
        expect(stop_reason).to eq(:stop)
      end

      client.chat_streaming(messages, ->(_, _) {}, on_complete)
    end

    context 'when the system prompt is empty' do
      let(:messages) do
        [
          { role: 'user', content: 'Hi' }
        ]
      end

      it 'is successful' do
        VCR.use_cassette('llm_clients/bedrock/streaming_empty_system_prompt', match_requests_on: %i[method uri body]) do
          expect(chat_streaming.success).to eq(true)
        end
      end
    end
  end
end
