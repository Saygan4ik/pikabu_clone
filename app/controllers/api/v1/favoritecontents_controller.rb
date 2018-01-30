# frozen_string_literal: true

module Api
  module V1
    class FavoritecontentsController < ApplicationController
      before_action :authenticate_user
      before_action :find_content, :find_or_create_favorite

      def add_to_favorites
        favoritecontent = find_favoritecontent
        message = if favoritecontent.empty?
                    @user.favoritecontents.create!(content: @content, favorite_id: @favorite&.id)
                    'Added to favorites'
                  else
                    'Has been added already'
                  end
        render json: { messages: message },
               status: :ok
      end

      def remove_from_favorites
        favoritecontent = find_favoritecontent
        raise ActiveRecord::RecordNotFound if favoritecontent.empty?
        favoritecontent.destroy_all
        render json: { messages: 'Remove from favorites' },
               status: :ok
      end

      private

      def find_favoritecontent
        favorite_id = @favorite ? @favorite.id : nil
        @user.favoritecontents.where(content: @content,
                                     favorite_id: favorite_id)
      end

      def find_content
        @content = Comment.find(params[:comment_id]) if params[:comment_id]
        @content = Post.find(params[:post_id]) if params[:post_id]

        unless @content
          render json: { messages: 'Bad_request' },
                 status: :bad_request
        end
      end

      def find_or_create_favorite
        @favorite = Favorite.find_or_create_by(name: params[:favorite_name]) if params[:favorite_name]
      end
    end
  end
end
