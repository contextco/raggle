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

    embedding = EmbeddingService.generate(params[:q])
    @documents = current_user.chunks.nearest_neighbors(:embedding, embedding, distance: :euclidean).limit(10).group_by(&:document)
  end
end
