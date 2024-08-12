# frozen_string_literal: true

class Settings::IntegrationComponent < ApplicationComponent
  attribute :icon
  attribute :title
  attribute :resource_name, default: :document
  attribute :integration_link
  attribute :connected, default: false
  attribute :resources

  def sentinel_connected_class
    "#{title.downcase.gsub(' ', '-')}-integration-connected"
  end
end