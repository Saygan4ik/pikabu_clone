Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'users/sessions#login'
      delete 'auth/logout', to: 'users/sessions#logout'
      post 'auth/register', to: 'users/registrations#register'

      get '', to: 'posts#index_hot'
      get 'best', to: 'posts#index_best'
      get 'new', to: 'posts#index_new'
      resources :posts, except: [:edit, :update]

      root 'posts#index_hot'
    end
  end
end
