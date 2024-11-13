Rails.application.routes.draw do
  # devise_for :users, controllers: {
  #   registrations: 'registrations'
  # }
  devise_for :users, controllers: { registrations: 'registrations' }

  # Add the custom route for update_profile here
  devise_scope :user do
    patch 'users/update_profile', to: 'registrations#update_profile', as: :update_profile
    get '/logout', to: 'devise/sessions#destroy', as: :logout
    get 'users/delete', to: 'registrations#delete', as: :delete_account
    delete 'users/destroy', to: 'registrations#destroy', as: :destroy_user
  end

  root 'users#index'
  get 'user/homepage', to: 'users#homepage', as: 'homepage'

  resources :users, only: [ :index, :update ]

  resources :products do
    member do
      get 'delete', to: 'products#delete', as: 'delete'
    end
    resources :reviews, only: [ :index, :new, :create, :edit, :update, :destroy ] do
      member do
        get 'delete', to: 'reviews#delete', as: 'delete'
      end
    end
  end

  resources :categories do
    member do
      get 'delete', to: 'categories#delete', as: 'delete'
    end
  end

  resources :reviews do
    member do
      get 'delete', to: 'reviews#delete', as: 'delete'
    end
  end

  resources :cart_items, only: [ :create, :update, :destroy ] do
    member do
      get 'delete', to: 'cart_items#delete', as: 'delete'
    end
  end
  resource :cart, only: [ :show ]

  resources :orders, only: [ :index, :show, :create ] do
    # member do
    #   patch :cancel
    # end

    resources :order_items, only: [ :show, :update ] do
      member do
        patch :update_status
        patch :assign_rider
      end
    end
  end
end
