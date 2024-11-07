Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  devise_scope :user do
    get '/logout', to: 'devise/sessions#destroy', as: :logout
    delete '/delete', to: 'devise/registrations#destroy', as: :delete_account
  end

  root 'users#index'
  get 'user/homepage', to: 'users#homepage', as: 'homepage'

  resources :users, only: [ :index, :update ]

  resources :products do
    member do
      get 'delete', to: 'products#delete', as: 'delete'
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

  resources :cart_items, only: [ :create, :update, :destroy ]
  resource :cart, only: [ :show ]

  resources :orders, only: [:index, :show, :create ] do
    member do
      patch :cancel
    end

    resources :order_items, only: [:show, :update] do
      member do
        patch :update_status
      end
    end
  end

  # resource :cart, only: [:show] do
  #   resources :cart_items, only: [:create, :update, :destroy], shallow: true do
  #     member do
  #       get 'delete', to: 'cart_items#delete', as: 'delete'
  #     end
  #   end
  # end

  # resources :cart_items do
  #   member do
  #     get 'delete', to: 'cart_items#delete', as: 'delete'
  #   end
  # end
  # resource :cart, only: [:show]
end
