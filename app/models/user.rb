# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :team
  has_many :chats, dependent: :destroy

  has_many :document_ownerships, class_name: 'UserDocumentOwnership', dependent: :delete_all
  has_many :documents, through: :document_ownerships

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, :database_authenticatable, omniauth_providers: %i[google_oauth2]

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    if user
      user.update!(
        name: data['name'],
        profile_picture_url: data['image']
      )
      return user
    end

    ActiveRecord::Base.transaction do
      t = Team.create!
      user = create_user_from_omniauth(data, t)
    end

    user
  end

  def self.create_user_from_omniauth(data, team)
    User.create!(
      name: data['name'],
      email: data['email'],
      profile_picture_url: data['image'],
      team:,
      password: Devise.friendly_token[0, 20]
    )
  end
end
