# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateNewMessageJob do
  let(:user) { create(:user) }
  describe '#perform' do
    let(:chat) { create(:chat) }
    let(:message) { create(:message, chat:) }

    it 'creates a new message' do
      expect do
        described_class.new.perform(message, 'Hello!')
      end.to change { chat.messages.count }.by(1)
    end

    context 'when the chat has files attached' do
      let(:file) { fixture_file_upload('spec/fixtures/files/sample.md') }
      let(:message) { create(:message, chat:, files: [file]) }

      it 'creates a new message' do
        expect do
          described_class.new.perform(message, 'Hello!')
        end.to change { chat.messages.count }.by(1)
      end
    end
  end
end
