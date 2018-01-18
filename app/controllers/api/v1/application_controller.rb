module Api
  module V1
    class ApplicationController < ActionController::API
      def authenticate_user
        token = request.headers['X-USER-TOKEN']
        return unauthorize unless token
        @user = User.find_by_token(token)
        return unauthorize unless @user
        @user
      end

      def unauthorize
        head status: :unauthorize
      end
    end
  end
end
