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
        @favorites = @user.favoritecontents.where(favorite_id: params[:id])
        if @favorites.empty?
          render json: { messages: 'Not found' },
                 status: :not_found
        else
          @response = []
          getting_contents
          render json: @response,
                 status: :ok
        end
      end

      def all
        @favorites = @user.favoritecontents
        if @favorites.empty?
          render json: { messages: 'Not found' },
                 status: :not_found
        else
          @response = []
          getting_contents

          render json: @response,
                 status: :ok
        end
      end

      private

      def getting_contents
        @favorites.each do |item|
          @response << if item.content_type == 'Post'
                         Post.find_by(id: item.content_id)
                       else
                         Comment.find_by(id: item.content_id)
                       end
        end
      end
    end
  end
end
