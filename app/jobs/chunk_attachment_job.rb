# frozen_string_literal: true

class ChunkAttachmentJob < ApplicationJob
  queue_as :default

  def perform(uploaded_file)
    return unless uploaded_file.attachment.attached? && uploaded_file.document.chunks.empty?

    content = uploaded_file.attachment.download
    uploaded_file.document.chunks.from_string!(uploaded_file.document, content)
  end
end
