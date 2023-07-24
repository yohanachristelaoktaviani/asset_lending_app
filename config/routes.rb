Rails.application.routes.draw do

  get 'user_asset_loans/index'
  get 'user_asset_loans/show'
  # get 'user_asset_return_items/index'
  # get 'user_asset_return_items/show'
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

  resources :items do
    collection do
      get :export_item, defaults: { format: 'csv' }
    end
  end
  resources :users do
    collection do
      get :export_user, defaults: { format: 'csv' }
    end
  end
  resources :asset_loans
  resources :asset_loans_items do
    post :accept, on: :member
    post :decline, on: :member
    post :cancel, on: :member
    collection do
      get :export_loan, defaults: { format: :csv }
    end
  end
  resources :asset_return_items do

    post :received, on: :member
    delete :destroy_aset, on: :collection
    collection do
      get :export_return, defaults: { format: :csv }
    end
  end

  resources :user_items

  resources :user_asset_loans

  resources :user_asset_returns do

    delete :destroy_aset, on: :collection
  end

  # post '/user_asset_returns/new/:id', to: 'user_asset_returns#create', as: :new_user_asset_return

  resources :asset_return

end
