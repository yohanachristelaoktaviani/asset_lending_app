Rails.application.routes.draw do

  devise_for :users, skip: [:registrations]
  root 'mains#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  authenticated :users do
    root to: 'items#index', as: 'authenticated_root'
  end

  resources :items
  resources :users

end
