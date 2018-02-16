# frozen_string_literal: true

module Api
  module V1
    class GraphqlController < ApplicationController
      def execute
        variables = ensure_hash(params[:variables])
        query = params[:query]
        context = {
          current_user: current_user,
          files: request.params[:files]
        }
        result = PikabuCloneSchema.execute(query,
                                           variables: variables,
                                           context: context)
        render json: result
      rescue ActiveRecord::RecordInvalid => e
        render json: e.message, status: :unprocessable_entity
      rescue Exceptions::Unauthorized
        render json: {}, status: :unauthorized
      rescue Exceptions::BadRequest
        render json: {}, status: :bad_request
      rescue Exceptions::Forbidden
        render json: {}, status: :forbidden
      end

      private

      def current_user
        token = request.headers['X-USER-TOKEN']
        return unless token
        user = User.find_by_token(token)
        return if !user || user.isBanned?
        user
      end

      # Handle form data, JSON body, or a blank value
      def ensure_hash(ambiguous_param)
        case ambiguous_param
        when String
          if ambiguous_param.present?
            ensure_hash(JSON.parse(ambiguous_param))
          else
            {}
          end
        when Hash, ActionController::Parameters
          ambiguous_param
        when nil
          {}
        else
          raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
        end
      end
    end
  end
end
