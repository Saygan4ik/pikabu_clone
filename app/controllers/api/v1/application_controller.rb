# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound do
        render json: {}, status: :not_found
      end

      def authenticate_user
        token = request.headers['X-USER-TOKEN']
        return unauthorize unless token
        @user = User.find_by_token(token)
        return unauthorize unless @user && !@user.isBanned?
        @user
      end

      def authenticate_admin
        unless @user.admin?
          render json: { messages: 'Access denied' },
                 status: :forbidden
        end
      end

      def unauthorize
        head status: :unauthorize
      end

      def pagination_dict(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
