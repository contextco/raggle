# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment
  include Heroicon::ApplicationHelper

  delegate :current_user, to: :helpers

  def initialize(**args)
    super
    assign_attributes(args)
  end
end
