# frozen_string_literal: true

module Api
  module V1
    class FavoritesController < ApplicationController
      before_action :authenticate_user

      def index
        @favorites = @user.favorites.uniq
        if @favorites.empty?
          render json: { messages: 'No favorites created' },
                 status: :ok
        else
          render json: @favorites,
                 status: :ok
        end
      end

      def show
        @favorites = @user.favoritecontents.where(favorite_id: params[:id])
        raise ActiveRecord::RecordNotFound if @favorites.empty?
        @response = []
        load_contents
        render json: @response,
               status: :ok
      end

      def contents
        @favorites = @user.favoritecontents
        raise ActiveRecord::RecordNotFound if @favorites.empty?
        @response = []
        load_contents
        render json: @response,
               status: :ok
      end

      private

      def load_contents
        @favorites.each do |item|
          @response << if item.content_type == 'Post'
                         Post.find(item.content_id)
                       else
                         Comment.find(item.content_id)
                       end
        end
      end
    end
  end
end
