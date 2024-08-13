# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :chats, only: %i[index create show update] do
    post 'chat', on: :member
  end

  resource :search, only: %i[show]

  resource :settings, only: %i[show update] do
    post 'resync', on: :collection
  end

  # Devise User Paths
  devise_for :users,
             path: '',
             skip: %i[registrations passwords],
             path_names: {
               sign_in: 'start',
               sign_out: 'logout'
             },
             controllers: {
               sessions: 'users/sessions'
             }

  # Omniauth Callbacks
  devise_scope :user do
    get '/auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2', as: :omniauth_callback
  end

  match '/auth/:provider', via: %i[post], as: :auth_provider, to: 'auth#create'
  scope '/_/permissions' do
    get '/google_with_google_drive/callback', to: 'auth#handle_google_callback'
    get '/google_with_gmail/callback', to: 'auth#handle_google_callback'
  end

  # Defines the root path route ("/")
  root 'chats#index'
end
