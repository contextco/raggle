# frozen_string_literal: true

class Users::SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_to_root, only: %i[new], if: :user_signed_in?

  def new; end

  def destroy
    sign_out
    redirect_to new_user_session_path
  end

  private

  def redirect_to_root
    redirect_to root_path
  end
end
