# frozen_string_literal: true

class UI::SidebarNavigationIconComponent < ApplicationComponent
  attribute :icon
  attribute :path

  def active?
    request.path.start_with?(path)
  end
end
