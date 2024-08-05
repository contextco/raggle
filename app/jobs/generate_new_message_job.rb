# frozen_string_literal: true

class GenerateNewMessageJob < ApplicationJob
  queue_as :default
  include ActionView::RecordIdentifier
  include ApplicationHelper

  def perform(input_message, output_message)
    generate_new_message(input_message, output_message)
  end

  private

  def generate_new_message(input_message, output_message)
    populate_embedding(input_message) if input_message.embedding.nil?

    chunk_documents(input_message.documents) if input_message.uploaded_files.present?

    outcome = llm_client(input_message.chat.model).chat_streaming(
      [
        *prior_messages(output_message.chat, output_message)
      ],
      stream_new_messages(output_message),
      ->(_finish_reason, content) { output_message.update!(content:) }
    )

    raise StandardError, outcome.full_json unless outcome.success
  end

  def populate_embedding(input_message)
    embedding = EmbeddingService.generate(input_message.content)
    input_message.update!(embedding:)
  end

  def chunk_documents(docs)
    return if docs.filter(&:uploaded_file?).all? { |files| files.chunks.present? }

    docs.filter(&:uploaded_file?).each do |document|
      next if document.chunks.present?

      content = document.attachment.download
      document.chunks.from_string!(document, content)
    end
  end

  def stream_new_messages(message)
    lambda { |_new_content, buffer|
      message.broadcast_action(
        :update_and_scroll_to_bottom,
        target: dom_id(message),
        html: markdown_to_html(buffer)
      )
    }
  end

  def prior_messages(chat, current_message)
    chat.messages.excluding(current_message).flat_map do |message|
      buf = message.top_k_chunks_grouped_by_document.flat_map do |document, chunks|
        {
          role: :system,
          content: <<~FILE
            The following is an excerpt from a user-uploaded file that may be relevant to the current conversation. Consider this information when formulating your response, if necessary.

            Filename: #{document.attachment.filename}

            Content:
            #{chunks.map(&:content).join("\n")}
          FILE
        }
      end
      buf << { role: message.role, content: message.content }
    end
  end

  def llm_client(model)
    @llm_client = LLM.from_string!(model).client
  end
end
