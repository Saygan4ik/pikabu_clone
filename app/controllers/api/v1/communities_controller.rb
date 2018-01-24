# frozen_string_literal:true

require_dependency 'app/services/post_finder'

module Api
  module V1
    class CommunitiesController < ApplicationController
      before_action :authenticate_user, only: %i[subscribe unsubscribe posts_subscriptions]

      def index
        @communities = Community.all
        if @communities
          render json: @communities,
                 each_serializer: CommunitySerializer,
                 status: :ok
        else
          render json: { messages: 'Not found communities' },
                 status: :ok
        end
      end

      def show
        @community = Community.find(params[:id])
        render json: @community,
               status: :ok
      end

      def subscribe
        @community = Community.find(params[:id])
        if @user.communities.exists?(@community.id)
          render json: { messages: 'You are already subscribed' },
                 status: :ok
        else
          @user.communities << @community
          render json: { messages: 'Thank you to subscribed' },
                 status: :ok
        end
      end

      def unsubscribe
        @community = Community.find(params[:id])
        if @user.communities.exists?(@community.id)
          @user.communities.delete(@community.id)
          render json: { messages: 'You unsubscribed from community' },
                 status: :ok
        else
          render json: { messages: 'You do not belong to the community' },
                 status: :ok
        end
      end

      def posts_new
        @posts = PostFinder.new(whitelisted_params).index_new
        @posts = @posts.where(community_id: params[:id])
        render_json
      end

      def posts_hot
        @posts = PostFinder.new(whitelisted_params).index_hot
        @posts = @posts.where(community_id: params[:id])
        render_json
      end

      def posts_best
        @posts = PostFinder.new(whitelisted_params).index_best
        @posts = @posts.where(community_id: params[:id])
        render_json
      end

      def posts_subscriptions
        @posts = PostFinder.new(whitelisted_params).index_new
        @posts = @posts.where(community_id: @user.communities)
        render_json
      end

      private

      def whitelisted_params
        params.permit(:start_date, :end_date,
                      :order, :order_by,
                      :page, :per_page)
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
