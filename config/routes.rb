Rails.application.routes.draw do
  root 'users#index'

  resources :users do
    collection do
      get 'sign_in', to: 'users#sign_in', as: 'sign_in'
      post 'create_session', to: 'users#create_session', as: 'create_session'
      get 'destroy_session', to: 'users#destroy_session', as: 'destroy_session'
    end
    member do
      get 'delete', to: 'users#delete', as: 'delete'  # Route for the delete confirmation page
    end
  end

  resources :products do
    member do
      get 'delete', to: 'products#delete', as: 'delete'
    end
  end

  # resources :products do
  #   member do
  #     get 'edit'
  #     patch 'update'
  #   end
  # end
end
