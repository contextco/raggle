# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    return unless params[:q].present?

    perform_search
    render :results
  end

  private

  def perform_search
    @query_id = SecureRandom.uuid
    PerformSearchJob.perform_later(params[:q], current_user, @query_id)

    # TODO: Should the default be to search by embedding? Generating an embedding for the query makes it slow.
    #       We could alternately do full-text search, but this would mean we need to un-encrypt the chunk content.
    embedding = EmbeddingService.generate(params[:q])
    @documents = Document.search_by_chunks(embedding, current_user.documents).limit(10)
  end
end
