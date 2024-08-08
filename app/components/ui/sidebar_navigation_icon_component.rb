# frozen_string_literal: true

class Ui::SidebarNavigationIconComponent < ApplicationComponent
  attribute :icon
  attribute :path

  def active?
    request.path.start_with?(path)
  end
end
