# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadedFile, type: :model do
  describe 'associations' do
    it { should have_one(:document).dependent(:destroy) }
    it { should have_one_attached(:attachment) }
  end

  describe 'callbacks' do
    let(:uploaded_file) { build(:uploaded_file) }

    it 'enqueues ChunkAttachmentJob after commit on create' do
      expect { uploaded_file.save! }.to have_enqueued_job(ChunkAttachmentJob).with(uploaded_file)
    end

    it 'enqueues ChunkAttachmentJob after commit on update' do
      uploaded_file.save!
      expect { uploaded_file.update!(updated_at: Time.now) }.to have_enqueued_job(ChunkAttachmentJob).with(uploaded_file)
    end
  end
end
