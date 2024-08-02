# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'associations' do
    it { should belong_to(:message) }
    it { should have_one_attached(:attachment) }
    it { should have_many(:chunks).dependent(:destroy) }
  end

  describe 'attributes' do
    it 'sets a default value for stable_id' do
      document = build(:document)
      expect(document.stable_id).to be_present
    end
  end

  describe 'callbacks' do
    let(:document) { build(:document) }

    it 'enqueues ChunkAttachmentJob after commit on create' do
      expect { document.save! }.to have_enqueued_job(ChunkAttachmentJob).with(document)
    end

    it 'enqueues ChunkAttachmentJob after commit on update' do
      document.save!
      expect { document.update!(updated_at: Time.now) }.to have_enqueued_job(ChunkAttachmentJob).with(document)
    end
  end
end
