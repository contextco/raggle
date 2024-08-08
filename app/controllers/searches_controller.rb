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
  end
end
