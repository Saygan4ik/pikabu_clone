Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'users/sessions#login'
      delete 'auth/logout', to: 'users/sessions#logout'
      post 'auth/register', to: 'users/registrations#register'
      patch 'auth/update', to: 'users/registrations#update'

      get '', to: 'posts#index_hot'
      get 'best', to: 'posts#index_best'
      get 'new', to: 'posts#index_new'
      get 'search', to: 'posts#search'
      post 'users/ban', to: 'users/users#ban_user'
      post 'post/like', to: 'posts#upvote'
      post 'post/dislike', to: 'posts#downvote'
      post 'comment/like', to: 'comments#upvote'
      post 'comment/dislike', to: 'comments#downvote'
      get 'comments/top_of_day', to: 'comments#top_comment'
      get 'comments/top50', to: 'comments#top50_comments'
      get 'favorites/contents', to: 'favorites#contents'
      post 'favorites/add', to: 'favoritecontents#add_to_favorites'
      delete 'favorites/remove', to: 'favoritecontents#remove_from_favorites'
      get 'communities/posts/subscriptions', to: 'communities#posts_subscriptions'
      resources :users, only: [:show], controller: 'users/users'
      resources :posts, except: [:edit, :update]
      resources :comments, except: [:edit, :update]
      resources :favorites, only: [:index, :show]
      resources :communities, only: [:index, :show] do
        member do
          get 'subscribe'
          get 'unsubscribe'
          get 'posts_new'
          get 'posts_hot'
          get 'posts_best'
        end
      end

      root 'posts#index_hot'
    end
  end

  mount Sidekiq::Web => '/sidekiq'
end
