# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChunkAttachmentJob, type: :job, vcr: { cassette_name: 'jobs/chunk_attachment_job' } do
  include ActiveJob::TestHelper

  let(:uploaded_file) { create(:uploaded_file) }
  let(:content) { 'a' * 5000 }
  let(:chunk_size) { Chunk::DEFAULT_SIZE }
  let(:chunk_overlap) { Chunk::DEFAULT_OVERLAP }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    uploaded_file.attachment.attach(
      io: StringIO.new(content),
      filename: 'test.txt',
      content_type: 'text/plain'
    )
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'creates chunks of appropriate size' do
    VCR.use_cassette('chunk_attachment_job/creates_chunks_of_appropriate_size') do
      ChunkAttachmentJob.perform_now(uploaded_file)

      total_chunks = if chunk_overlap < chunk_size
                       (content.size.to_f / (chunk_size - chunk_overlap)).ceil
                     else
                       1
                     end
      expect(uploaded_file.document.chunks.count).to eq(total_chunks)
    end
  end

  it 'creates chunks with correct content' do
    VCR.use_cassette('chunk_attachment_job/creates_chunks_with_correct_content') do
      ChunkAttachmentJob.perform_now(uploaded_file)

      uploaded_file.document.chunks.each_with_index do |chunk, index|
        start_index = index * (chunk_size - chunk_overlap)
        end_index = [start_index + chunk_size, content.size].min

        expected_content = content[start_index...end_index].force_encoding(Encoding::ASCII_8BIT)

        expect(chunk.content).to eq(expected_content)
      end
    end
  end

  it 'does not create chunks if already present' do
    VCR.use_cassette('chunk_attachment_job/does_not_create_chunks_if_already_present') do
      ChunkAttachmentJob.perform_now(uploaded_file)
      expect { ChunkAttachmentJob.perform_now(uploaded_file) }.not_to(change { uploaded_file.document.chunks.count })
    end
  end

  it 'does not create chunks if attachment is not present' do
    VCR.use_cassette('chunk_attachment_job/does_not_create_chunks_if_attachment_not_present') do
      uploaded_file.attachment.detach
      uploaded_file.document.chunks.destroy_all
      expect(uploaded_file.document.chunks).to be_empty

      expect { ChunkAttachmentJob.perform_now(uploaded_file) }.not_to(change { uploaded_file.document.chunks.count })
    end
  end
end
