Rails.application.routes.draw do
  root 'users#index'
  resources :users, only: [:new, :create] do
    collection do
      get :sign_in
      post :create_session
      delete :destroy_session
    end
  end
  get 'products', to: 'users#products'
end
