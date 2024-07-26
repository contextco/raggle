# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!

    def new; end

    def destroy
      sign_out
      redirect_to new_user_session_path
    end
  end
end
