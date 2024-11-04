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
end
