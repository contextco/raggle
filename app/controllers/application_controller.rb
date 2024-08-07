# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  layout :set_layout

  private

  def unauthenticated
    redirect_to users_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def set_layout
    return 'layouts/authenticated' if user_signed_in?

    'application'
  end
end
