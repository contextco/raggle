# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :team
  has_many :chats, dependent: :destroy

  has_many :document_ownerships, class_name: 'UserDocumentOwnership', dependent: :delete_all
  has_many :documents, through: :document_ownerships
  has_many :chunks, through: :documents

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable

  store_accessor :google_oauth, :credentials, prefix: true

  def self.from_omniauth(access_token_payload)
    data = access_token_payload.info
    user = User.find_by(email: data['email'])

    if user
      user.update!(
        name: data['name'],
        profile_picture_url: data['image']
      )
      return user
    end

    ActiveRecord::Base.transaction do
      team = Team.create!
      user = team.users.create_user_from_omniauth(access_token_payload)
    end

    user
  end

  def self.create_user_from_omniauth(access_token_payload)
    data = access_token_payload.info
    create!(
      name: data['name'],
      email: data['email'],
      profile_picture_url: data['image'],
      google_oauth: access_token_payload,
      password: Devise.friendly_token[0, 20]
    )
  end

  def google_docs_permission_granted?
    google_oauth_scopes.include?(Ingestors::Google::Docs::REQUIRED_SCOPE)
  end

  def gmail_permission_granted?
    google_oauth_scopes.include?(Ingestors::Google::Gmail::REQUIRED_SCOPE)
  end

  def google_oauth_scopes
    google_oauth_credentials['scope'].split
  end
end
