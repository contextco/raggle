# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :chats, only: %i[index create show update] do
    post 'chat', on: :member
  end

  resource :search, only: %i[show create]

  # Devise User Paths
  devise_for :users,
             path: '',
             skip: %i[registrations passwords],
             path_names: {
               sign_in: 'start',
               sign_out: 'logout'
             },
             controllers: {
               omniauth_callbacks: 'users/omniauth_callbacks',
               sessions: 'users/sessions'
             }

  # Defines the root path route ("/")
  root 'chats#index'
end
