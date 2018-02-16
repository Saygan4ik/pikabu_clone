Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api/v1/graphql"
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post :graphql, to: 'graphql#execute'

      post 'auth/login', to: 'users/sessions#login'
      delete 'auth/logout', to: 'users/sessions#logout'
      post 'auth/register', to: 'users/registrations#register'
      patch 'auth/update', to: 'users/registrations#update'
      resources :users, only: [:show], controller: 'users/users' do
        collection do
          post :ban, to: 'users/users#ban_user'
        end
      end
      resources :posts, except: [:edit, :update] do
        collection do
          post :like, to: 'posts#upvote'
          post :dislike, to: 'posts#downvote'
          get :hot
          get :best
          get :recent
          get :search
        end
      end
      resources :comments, except: [:edit, :update] do
        collection do
          post :like, to: 'comments#upvote'
          post :dislike, to: 'comments#downvote'
          get :top_comment
          get :top50_comments
        end
      end
      resources :favorites, only: [:index, :show] do
        collection do
          get :contents, to: 'favorites#contents'
          post :add, to: 'favoritecontents#add_to_favorites'
          delete :remove, to: 'favoritecontents#remove_from_favorites'
        end
      end
      resources :communities, only: [:index, :show] do
        member do
          post 'subscribe'
          post 'unsubscribe'
          get 'posts_new'
          get 'posts_hot'
          get 'posts_best'
        end
        collection do
          get :posts_subscriptions, to: 'communities#posts_subscriptions'
        end
      end

      root 'posts#hot'
    end
  end

  mount Sidekiq::Web => '/sidekiq'
end
