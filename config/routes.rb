Rails.application.routes.draw do

  devise_for :users, skip: [:registrations]

  authenticated :user, ->(u) { u.role != 'admin' } do
    root 'user_items#index', as: :user_authenticated_root
  end

  authenticated :user, ->(u) { u.role == 'admin' } do
    root 'items#index', as: :admin_authenticated_root
  end

  root 'mains#index', as: :unauthenticated_root

  # root 'mains#index'

  # authenticated :users do
  #   root to: 'items#index', as: 'authenticated_root'
  # end

  resources :items
  resources :users
  resources :asset_loans
  resources :asset_loans_items do
    post :accept, on: :member
    post :decline, on: :member
    post :cancel, on: :member
  end
  resources :asset_return_items do
    post :received, on: :member
  end
  resources :user_items
  resources :user_asset_loans
end
