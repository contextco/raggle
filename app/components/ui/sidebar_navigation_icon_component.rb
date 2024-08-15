# frozen_string_literal: true

class Ui::SidebarNavigationIconComponent < ApplicationComponent
  attribute :icon
  attribute :path
  attribute :root, default: false

  def active?
    return true if root && request.path == '/'

    request.path.start_with?(path)
  end
end
