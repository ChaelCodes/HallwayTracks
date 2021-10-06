# frozen_string_literal: true

Rails.application.routes.draw do
  root "support#about"

  devise_for :users

  resources :support
  resources :events
  resources :event_attendees
  resources :friendships
  resources :profiles
  resources :users, except: :create
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/about", to: "support#about"
end
