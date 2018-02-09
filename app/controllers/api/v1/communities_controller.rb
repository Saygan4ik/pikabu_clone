# frozen_string_literal:true

module Api
  module V1
    class CommunitiesController < ApplicationController
      before_action :authenticate_user,
                    only: %i[subscribe unsubscribe posts_subscriptions]

      def index
        @communities = Community.all
        raise ActiveRecord::RecordNotFound unless @communities
        render json: @communities,
               each_serializer: CommunitySerializer,
               status: :ok
      end

      def show
        @community = Community.find(params[:id])
        render json: @community,
               status: :ok
      end

      def subscribe
        @community = Community.find(params[:id])
        message = if @user.communities.exists?(@community.id)
                    'You are already subscribed'
                  else
                    @user.communities << @community
                    'Thank you to subscribe'
                  end
        render json: { messages: message },
               status: :ok
      end

      def unsubscribe
        @community = Community.find(params[:id])
        message = if @user.communities.exists?(@community.id)
                    @user.communities.delete(@community.id)
                    'You unsubscribe from community'
                  else
                    'You do not belong to the community'
                  end

        render json: { messages: message },
               status: :ok
      end

      def posts_new
        @posts = PostFinder.new(whitelisted_params).index_new
        render_json
      end

      def posts_hot
        @posts = PostFinder.new(whitelisted_params).index_hot
        render_json
      end

      def posts_best
        @posts = PostFinder.new(whitelisted_params).index_best
        render_json
      end

      def posts_subscriptions
        raise ActiveRecord::RecordNotFound, 'no subscriptions' if @user.communities.empty?
        @posts = PostFinder.new(whitelisted_params).index_new
        render_json
      end

      private

      def whitelisted_params
        params.permit(:start_date, :end_date,
                      :order, :order_by,
                      :page, :per_page)
        params[:community_id] = if params[:id].present?
                                  params[:id]
                                else
                                  @user.community_ids
                                end
        params
      end

      def render_json
        render json: @posts,
               each_serializer: PostSerializer,
               meta: pagination_dict(@posts),
               status: :ok
      rescue ArgumentError => e
        render json: { error: e.message }, status: :bad_request
      end
    end
  end
end
