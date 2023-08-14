Rails.application.routes.draw do

  # get 'user_asset_return_items/index'
  # get 'user_asset_return_items/show'
  devise_for :users, skip: [:registrations]

  authenticated :user, ->(u) { u.role != 'admin' } do
    root 'dashboards#index', as: :user_authenticated_root
  end

  authenticated :user, ->(u) { u.role == 'admin' } do
    root 'dashboards#index', as: :admin_authenticated_root
  end

  root 'mains#index', as: :unauthenticated_root

  # root 'mains#index'

  # authenticated :users do
  #   root to: 'items#index', as: 'authenticated_root'
  # end

  resources :items do
    collection do
      get :download_template
      get :export_item, defaults: { format: 'csv' }
    end
    collection do
      post :import_item, defaults: {format: 'csv'}
    end
    member do
      get 'history', to: 'items#history'
    end
  end

  get 'users/:id/reset_password', to: 'users#reset_password', as: "reset_password"
  get 'users/reset_password_header', to: 'users#reset_password_header', as: "reset_password_header"

  get 'users/change_password', to: 'users#change_password_form', as: "change_password"
  post 'users/update_password', to: 'users#update_password', as: "update_password"

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

  delete '/remove_asset_loan_item', to: 'user_asset_returns#remove_asset_loan_item'

  resources :user_items

  resources :user_asset_loans

  resources :user_asset_returns do
    delete :destroy_aset, on: :collection
  end

  namespace :admin do
    resources :asset_loans_items
  end

  # post '/user_asset_returns/new/:id', to: 'user_asset_returns#create', as: :new_user_asset_return

  resources :asset_return
  resources :dashboards

end