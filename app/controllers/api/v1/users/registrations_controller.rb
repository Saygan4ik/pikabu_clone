# frozen_string_literal: true

module Api
  module V1
    module Users
      class RegistrationsController < ApplicationController
        before_action :authenticate_user, only: :update

        def register
          @user = User.new(user_params)
          if @user.save
            UserMailer.welcome_email(@user).deliver_later
            render json: { message: 'Registration completed successfully' },
                   status: :ok
          else
            render json: @user.errors.full_messages,
                   status: :unprocessable_entity
          end
        end

        def update
          if @user.try(:authenticate, params[:old_password])
            if @user.update_attributes(password: params[:password],
                                       password_confirmation: params[:password_confirmation])
              render json: { messages: 'Password changed' },
                     status: :ok
            else
              render json: @user.errors.full_messages,
                     status: :unprocessable_entity
            end
          else
            render json: { messages: 'Password is not valid' },
                   status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(:nickname, :email,
                                       :password, :password_confirmation)
        end
      end
    end
  end
end
