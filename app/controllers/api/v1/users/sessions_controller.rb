module Api
  module V1
    module Users
      class SessionsController < ApplicationController
        def login
          @user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
          if @user
            regenerate_token
            if @user.save
              render json: { 'X-USER-TOKEN': @user.token },
                     status: :ok
            else
              render json: @user.errors.full_messages,
                     status: :unprocessable_entity
            end
          else
            render json: { messages: 'Incorrect email or password' },
                   status: :unprocessable_entity
          end
        end

        def logout
          if authenticate_user
            @user.token = nil
            @user.save
            render json: { messages: 'Logout successfully' },
                   status: :ok
          end
        end

        private

        def regenerate_token
          token = SecureRandom.base58(24)
          while User.where(token: token).exists?
            token = SecureRandom.base58(24)
          end
          @user.token = token
        end
      end
    end
  end
end
