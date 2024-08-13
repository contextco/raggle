# frozen_string_literal: true

class SettingsController < ApplicationController
  def show; end

  def resync
    integration = Integration.from_key!(params[:integration_key])
    integration.backfill!(current_user)
  end
end
