# frozen_string_literal: true

module Api
  module V1
    class FavoritesController < ApplicationController
      before_action :authenticate_user

      def index
        @favorites = @user.favorites.uniq
        render json: @favorites,
               status: :ok
      end

      def show
        @favorites = @user.favoritecontents.find_by(favorite_id: params[:id])
        if @favorites.empty?
          render json: { messages: 'Not found' },
                 status: :not_found
        else
          @response = []
          load_contents
          render json: @response,
                 status: :ok
        end
      end

      def contents
        @favorites = @user.favoritecontents
        if @favorites.empty?
          render json: { messages: 'Not found' },
                 status: :not_found
        else
          @response = []
          load_contents

          render json: @response,
                 status: :ok
        end
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
