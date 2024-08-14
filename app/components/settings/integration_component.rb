# frozen_string_literal: true

class Settings::IntegrationComponent < ApplicationComponent
  attribute :icon
  attribute :title
  attribute :resource_name, default: :document
  attribute :integration_link
  attribute :connected, default: false
  attribute :resources
  attribute :integration_key

  def sentinel_connected_class
    "#{title.downcase.gsub(' ', '-')}-integration-connected"
  end

  def sync_in_progress?
    SyncLog.latest(integration_key)&.in_progress?
  end
end
