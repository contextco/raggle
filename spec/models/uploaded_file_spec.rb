# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadedFile, type: :model do
  describe 'associations' do
    it { should have_one(:document).dependent(:destroy) }
    it { should have_one_attached(:attachment) }
  end

  describe 'callbacks' do
    let(:uploaded_file) { build(:uploaded_file) }

    it 'calls #chunk_attachment after commit on create' do
      expect(uploaded_file).to receive(:chunk_attachment)
      uploaded_file.save!
    end

    it 'calls #chunk_attachment after commit on update' do
      uploaded_file.save!
      expect(uploaded_file).to receive(:chunk_attachment)
      uploaded_file.update!(updated_at: Time.now)
    end
  end

  describe 'chunk_attachment', vcr: { cassette_name: 'openai_embeddings/embeddings' } do
    let(:uploaded_file) { create(:uploaded_file) }
    let(:content) { 'a' * 5000 }
    let(:chunk_size) { Chunk::DEFAULT_SIZE }
    let(:chunk_overlap) { Chunk::DEFAULT_OVERLAP }

    before do
      uploaded_file.attachment.attach(
        io: StringIO.new(content),
        filename: 'test.txt',
        content_type: 'text/plain'
      )
    end

    it 'creates chunks of appropriate size after the document is created' do
      total_chunks = if chunk_overlap < chunk_size
                       (content.size.to_f / (chunk_size - chunk_overlap)).ceil
                     else
                       1
                     end
      expect(uploaded_file.document.chunks.count).to eq(total_chunks)
    end

    it 'creates chunks with correct content' do
      uploaded_file.send(:chunk_attachment)

      uploaded_file.document.chunks.each_with_index do |chunk, index|
        start_index = index * (chunk_size - chunk_overlap)
        end_index = [start_index + chunk_size, content.size].min

        expected_content = content[start_index...end_index].force_encoding(Encoding::ASCII_8BIT)

        expect(chunk.content).to eq(expected_content)
      end
    end

    it 'does not create chunks if already present' do
      expect { uploaded_file.send(:chunk_attachment) }.not_to(change { uploaded_file.document.chunks.count })
    end

    it 'does not create chunks if attachment is not present' do
      uploaded_file.attachment.detach
      uploaded_file.document.chunks.destroy_all
      expect(uploaded_file.document.chunks).to be_empty
      expect { uploaded_file.send(:chunk_attachment) }.not_to(change { uploaded_file.document.chunks.count })
    end
  end
end
