# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chunk, type: :model do
  describe 'associations' do
    it { should belong_to(:document) }
  end

  describe 'validations' do
    it { should validate_presence_of(:chunk_index) }
    it { should validate_presence_of(:content) }
  end

  describe 'callbacks' do
    let(:chunk) { build(:chunk, content: 'test content', embedding: nil) }

    it 'generates embedding before creating a chunk' do
      expect(chunk).to receive(:generate_embedding)
      chunk.save!
    end

    it 'enqueues GenerateEmbeddingsJob after commit on create' do
      expect { chunk.save! }.to have_enqueued_job(GenerateEmbeddingsJob).with(chunk)
    end
  end
end
