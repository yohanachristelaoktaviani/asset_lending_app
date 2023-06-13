Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  authenticated :user do
    root 'items#index', as: :authenticated_root
  end

  unauthenticated :user do
    root 'mains#index', as: :unauthenticated_root
  end
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

end
