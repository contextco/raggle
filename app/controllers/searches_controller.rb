class SearchesController < ApplicationController
  def show; end

  def create
    @query_id = SecureRandom.uuid
    PerformSearchJob.perform_later(params[:q], current_user, @query_id)
  end
end
