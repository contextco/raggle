# frozen_string_literal: true

class AuthController < ApplicationController
  # Left intentionally blank as the route is hijacked by omniauth middleware.
  # We only create the routes and controller action here to generate route helpers.
  def create; end

  def handle_google_callback
    current_user.update!(
      google_oauth: current_user
                      .google_oauth
                      .deep_merge(request.env['omniauth.auth'])
    )

    redirect_to settings_path
  end
end
