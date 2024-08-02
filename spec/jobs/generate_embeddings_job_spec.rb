# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateEmbeddingsJob do
  describe '#perform' do
    let(:chunk) { create(:chunk, content: 'test content', embedding: nil) }

    it 'populates the embedding field with embeddings', vcr: { cassette_name: 'jobs/generate_embeddings_job' } do
      described_class.new.perform(chunk)
      expect(chunk.embedding).to be_present
    end
  end
end
