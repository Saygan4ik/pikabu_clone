# frozen_string_literal: true

module Api
  module V1
    class FavoritecontentsController < ApplicationController
      before_action :authenticate_user
      before_action :find_content, :find_or_create_favorite

      def add_to_favorites
        @favoritecontent = find_favoritecontent
        if @favoritecontent.empty?
          @favoritecontent = Favoritecontent.new(user_id: @user.id,
                                                 content: @content)
          @favoritecontent.favorite_id = @favorite.id if @favorite
          @favoritecontent.save
          render json: { messages: 'Added to favorites' },
                 status: :ok
        else
          render json: { messages: 'Has been added already' },
                 status: :ok
        end
      end

      def remove_from_favorites
        @favoritecontent = find_favoritecontent
        if @favoritecontent.empty?
          render json: { messages: 'not found' },
                 status: :not_found
        else
          Favoritecontent.all.delete(@favoritecontent)
          render json: { messages: 'Remove from favorites' },
                 status: :ok
        end
      end

      private

      def find_favoritecontent
        @favcontent = Favoritecontent.where(user_id: @user.id,
                                            content: @content)
        @favcontent = if @favorite
                        @favcontent.where(favorite_id: @favorite.id)
                      else
                        @favcontent.where(favorite_id: nil)
                      end
      end

      def find_content
        if params[:post_id] || params[:comment_id]
          @content = Comment.find(params[:comment_id]) if params[:comment_id]
          @content = Post.find(params[:post_id]) if params[:post_id]
        else
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
