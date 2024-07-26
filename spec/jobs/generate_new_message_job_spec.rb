# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateNewMessageJob do
  let(:user) { create(:user) }
  describe '#perform', vcr: { cassette_name: 'jobs/generate_new_message_job' } do
    let(:chat) { create(:chat) }
    let!(:input_message) { create(:message, chat:, content: 'hi there', role: :user) }
    let!(:output_message) { create(:message, chat:, content: '', role: :assistant) }

    it 'update a new message' do
      expect do
        described_class.new.perform(input_message, output_message)
      end.to change { chat.messages.last.content }.from('')
    end

    context 'when the chat has files attached', vcr: { cassette_name: 'jobs/generate_new_message_job/with_file_attached' } do
      let(:file) { fixture_file_upload('spec/fixtures/files/sample.md') }
      let(:input_message) { create(:message, chat:, content: 'test', files: [file]) }

      it 'updates the last message' do
        expect do
          described_class.new.perform(input_message, output_message)
        end.to change { chat.messages.last.content }.from('')
      end
    end
  end
end
