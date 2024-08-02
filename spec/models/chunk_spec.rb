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
    let(:chunk) { build(:chunk, content: 'test content') }

    it 'generates embedding before creating a chunk' do
      expect(chunk).to receive(:generate_embedding)
      chunk.save
    end

    it 'sets the embedding attribute with correct dimensions' do
      embedding_mock = Array.new(1536, 0.1)
      allow(EmbeddingService).to receive(:generate).with('test content').and_return(embedding_mock)
      chunk.save
      expect(chunk.embedding).to eq(embedding_mock)
      expect(chunk.embedding.size).to eq(1536)
    end
  end
end
