# frozen_string_literal: true

module Api
  module V1
    module Users
      class UsersController < ApplicationController
        before_action :authenticate_user, only: :ban_user
        before_action :user_admin, only: :ban_user

        def show
          @user = User.find(params[:id])
          render json: @user,
                 serializer: UserprofileSerializer,
                 status: :ok
        end

        def ban_user
          @user = User.find(params[user_id])
          timeout_ban = set_timeout_ban
          @user.update(isBanned: true, timeoutBan: timeout_ban)
        end

        private

        def set_timeout_ban
          Time.current + params[:months].months + params[:days].days + params[:hours].hours
        end
      end
    end
  end
end
