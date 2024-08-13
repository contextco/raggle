# frozen_string_literal: true

module SearchesHelper
  def link_to_gmail_message(message_id)
    base = URI("https://mail.google.com/mail/#inbox/#{message_id}")
    base.query = URI.encode_www_form(authuser: current_user.email)
    base.to_s
  end
end
