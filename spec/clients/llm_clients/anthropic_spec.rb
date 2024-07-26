# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LLMClients::Anthropic do
  describe '#chat', vcr: { cassette_name: 'llm_clients/anthropic/chat' } do
    let(:llm) { LLM.from_string!('claude-3-sonnet-20240229') }
    let(:anthropic_client) { described_class.new(llm:) }
    let(:messages) { [{ role: :user, content: 'Hello, how are you?' }] }
    let(:response) { anthropic_client.chat(messages) }

    it 'returns a response' do
      expect(response).to be_a(LLMClients::Response)
    end

    it 'returns a response with content' do
      expect(response.content).to be_a(String)
    end

    it 'returns a response with full_json' do
      expect(response.full_json).to be_a(Hash)
    end

    it 'returns a response with success' do
      expect(response.success).to be_truthy
    end

    it 'returns a response with stop_reason' do
      expect(response.stop_reason).to eq(:stop)
    end
  end

  describe '#chat_streaming',
           vcr: { cassette_name: 'llm_clients/anthropic/chat_streaming' } do
    let(:llm) { LLM.from_string!('claude-3-sonnet-20240229') }
    let(:anthropic_client) { described_class.new(llm:) }
    let(:messages) { [{ role: :user, content: 'Hello, how are you?' }] }
    let(:on_message) { ->(new_content, _buffer) { new_content } }
    let(:complete_proc) { ->(finish_reason, _buffer) { finish_reason } }
    subject(:response) { anthropic_client.chat_streaming(messages, on_message, complete_proc) }

    let(:expected_response) do
      <<~RESPONSE
        Hello! As an AI language model, I don't have subjective experiences like emotions, but I'm operating properly and ready to assist you with any questions or tasks you may have. How can I help you today?
      RESPONSE
        .strip
    end

    it { is_expected.to be_a(LLMClients::Response) }

    it 'returns a response with content' do
      expect(response.content).to eq(expected_response.strip)
    end

    it 'returns a response with full_json' do
      expect(response.full_json).to be_a(Array)
    end

    it 'returns a response with success' do
      expect(response.success).to be_truthy
    end

    it 'returns a response with stop_reason' do
      expect(response.stop_reason).to eq(:stop)
    end

    it 'calls on_message with all the delta chunks' do
      buffer = String.new
      on_message = ->(new_content, _buffer) { buffer << new_content }
      anthropic_client.chat_streaming(messages, on_message, complete_proc)

      expect(buffer).to eq(expected_response)
    end

    it 'calls complete_proc' do
      expect(complete_proc).to receive(:call).at_least(:once).with('end_turn', expected_response)
      response
    end

    context 'when the messages have multiple system messages',
            vcr: { cassette_name: 'llm_clients/anthropic/chat_streaming_multiple_system_prompts' } do
      let(:messages) do
        [
          { role: :system, content: 'Hello, how are you?' },
          { role: :user, content: 'Hello, how are you?' },
          { role: :system, content: 'Hello, how are you?' }
        ]
      end
      let(:expected_response) do
        <<~RESPONSE
          Hello! As an AI language model, I don't have feelings, but I'm operating properly and ready to assist you with any questions or tasks you may have. How can I help you today?
        RESPONSE
          .strip
      end

      it 'still succeeds' do
        expect(response.success).to be_truthy
      end

      it 'combines the system messages into one' do
        expect(response.content).to eq(expected_response)
      end
    end
  end
end
