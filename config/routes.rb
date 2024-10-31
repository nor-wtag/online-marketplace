Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    get '/logout', to: 'devise/sessions#destroy', as: :logout
  end

  root 'users#index'
  # resources :users do
  #   collection do
  #     get 'sign_in', to: 'users#sign_in', as: 'sign_in'
  #     post 'create_session', to: 'users#create_session', as: 'create_session'
  #     get 'destroy_session', to: 'users#destroy_session', as: 'destroy_session'
  #   end
  #   member do
  #     get 'delete', to: 'users#delete', as: 'delete'
  #   end
  # end
  # 
  # resources :users, only: [:index, :show, :edit, :update, :destroy]
  resources :users, only: [:index, :edit, :update, :destroy] do
    member do
      get 'delete'
    end
  end
  resources :products, only: [:index, :show] do
    member do
      get 'delete', to: 'products#delete', as: 'delete'
    end
  end
end
