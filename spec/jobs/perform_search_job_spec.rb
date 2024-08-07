# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PerformSearchJob, type: :job do
  include ActionView::TestCase::Behavior
  include ActionCable::TestHelper
  include ApplicationHelper

  let(:user) { create(:user) }

  describe '#perform', vcr: 'jobs/perform_search_job' do
    let(:query_id) { SecureRandom.uuid }

    it 'successfully executes' do
      described_class.perform_now('foo', user, query_id)
    end

    it 'broadcasts the search results' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        described_class.perform_now('foo', user, query_id)
      end.to broadcast_to(query_id).at_least(:once)
    end

    context 'when the llm responses are hardcoded' do
      let(:mock_openai) { instance_double(LLMClients::OpenAi) }

      before do
        allow(LLMClients::OpenAi).to receive(:new).and_return(mock_openai)
        allow(mock_openai).to receive(:embedding).and_return(Array.new(1536))
        allow(mock_openai).to receive(:chat_streaming) do |_messages, on_message, on_complete|
          on_message.call('full', 'full')
          on_message.call(' message', 'full message')
          on_complete.call(:done, 'full message')
        end
      end

      it 'broadcasts the search results' do
        ActiveJob::Base.queue_adapter = :test
        expect do
          described_class.perform_now('foo', user, query_id)
        end.to broadcast_to(query_id).once.with(
          Turbo::Streams::TagBuilder.new(view).action(
            :update_and_scroll_to_bottom,
            :generative_summary,
            html: "<p>full message</p>\n".html_safe
          )
        )
      end
    end
  end
end
