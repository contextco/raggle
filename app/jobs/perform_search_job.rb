# frozen_string_literal: true

class PerformSearchJob < ApplicationJob
  queue_as :real_time

  include ApplicationHelper

  def perform(query, user, query_id)
    query_embedding = EmbeddingService.generate(query)

    relevant_chunks = user.chunks.nearest_neighbors(:embedding, query_embedding, distance: :euclidean).limit(10)

    render_generative_summary(query, relevant_chunks, query_id)
  end

  private

  def render_generative_summary(query, relevant_chunks, query_id)
    llm_client.chat_streaming(
      [
        {
          role: 'system',
          content: Prompt.new(:search).render_to_string(chunks: relevant_chunks)
        },
        {
          role: 'user',
          content: query
        }
      ],
      stream_new_tokens(query_id),
      ->(_finish_reason, content) {}
    )
  end

  def stream_new_tokens(query_id)
    lambda do |_new_content, buffer|
      Turbo::StreamsChannel.broadcast_action_to(
        query_id,
        action: :update_and_scroll_to_bottom,
        target: :generative_summary,
        html: markdown_to_html(buffer)
      )
    end
  end

  def llm_client
    # TODO: Make configurable
    LLM.from_string!('gpt-4o-mini').client
  end
end
