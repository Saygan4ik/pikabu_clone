# frozen_string_literal: true

module Api
  module V1
    module Users
      class UsersController < ApplicationController
        before_action :authenticate_user, only: :ban_user
        before_action :user_admin, only: :ban_user

        def show
          @user = User.find(params[:id])
          @user.posts_order = 'time' if params[:order] == 'time'
          @user.posts_page = params[:page] if params[:page]
          render json: @user,
                 status: :ok
        end

        def ban_user
          @user = User.find(params[:user_id])
          timeout_ban = definition_timeout_ban(params[:ban_time])
          @user.update(isBanned: true, timeoutBan: timeout_ban)
          render json: { messages: 'User banned' },
                 status: :ok
        rescue ArgumentError => e
          render json: { error: e.message }, status: :bad_request
        end

        private

        def definition_timeout_ban(ban_time)
          raise ArgumentError, 'ban time must be a number' unless ban_time.is_i?
          timeout_ban = Time.current.to_i + ban_time.to_i
          Time.at(timeout_ban).to_datetime
        end
      end
    end
  end
end
