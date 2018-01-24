# frozen_string_literal: true

module Api
  module V1
    module Users
      class UsersController < ApplicationController
        def show
          @user = User.find(params[:id])
          render json: @user,
                 serializer: UserprofileSerializer,
                 status: :ok
        end
      end
    end
  end
end
