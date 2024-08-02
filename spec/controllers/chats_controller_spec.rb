# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'loads successfully' do
      get chats_path
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    it 'redirects to the created chat' do
      post chats_path, params: { chat: { model: 'gpt-4o-mini', content: 'hi this is a message' } }
      expect(response).to redirect_to(chat_path(Chat.last))
    end

    it 'creates a chat' do
      expect do
        post chats_path, params: { chat: { model: 'gpt-4o-mini', content: 'hi this is a message' } }
      end.to change(user.chats.reload, :count).by(1)
    end
  end

  describe 'GET #show' do
    let(:chat) { create(:chat, user:) }

    it 'loads successfully' do
      get chat_path(chat)
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    let(:chat) { create(:chat, user:) }
    let(:params) { { chat: { content: 'hi this is a message' } } }

    it 'redirects to the chat' do
      put chat_path(chat, params:)
      expect(response).to redirect_to(chat_path(chat))
    end

    it 'creates two new messages' do
      expect do
        put chat_path(chat, params:)
      end.to change(chat.messages.reload, :count).by(2)
    end

    it 'queues generation of new messages' do
      expect do
        put chat_path(chat, params:)
      end.to have_enqueued_job(GenerateNewMessageJob)
    end

    it 'saves the new messages', vcr: { cassette_name: 'chats/new_message' } do
      perform_enqueued_jobs do
        put chat_path(chat, params:)
      end

      expect(chat.messages.user_role.last.content).to eq('hi this is a message')
      expect(chat.messages.assistant_role.last.content).to be_present
    end

    context 'when a file is attached', vcr: { cassette_name: 'chats/new_message/with_file' } do
      let(:file) { fixture_file_upload('gg.txt') }
      let(:blob) { ActiveStorage::Blob.create_and_upload!(io: file, filename: 'gg.txt', content_type: 'text/plain') }
      let(:params) { { chat: { content: 'hi this is a message', files: [blob.signed_id] } } }

      it 'attaches the file to the message' do
        expect do
          put chat_path(chat, params:)
        end.to change(ActiveStorage::Attachment, :count).by(1)
      end

      it 'associates the created document to the user' do
        put chat_path(chat, params:)
        expect(UserDocumentOwnership.find_by(user:, document: chat.documents.last)).to be_present
      end
    end
  end
end
