module Api
  module V1
    module Users
      class RegistrationsController < ApplicationController
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

        private

        def user_params
          params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
        end
      end
    end
  end
end
