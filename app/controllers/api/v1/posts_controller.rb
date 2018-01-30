# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user, only: %i[create upvote downvote destroy]
      before_action :user_admin, only: :destroy

      def index
        @posts = Post.order(created_at: :desc)
                     .page(params[:page])
                     .per(params[:per_page])
        render_json
      end

      def index_hot
        @posts = PostFinder.new(whitelisted_params).index_hot
        render_json
      end

      def index_best
        @posts = PostFinder.new(whitelisted_params).index_best
        render_json
      end

      def index_new
        @posts = PostFinder.new(whitelisted_params).index_new
        render_json
      end

      def show
        @post = Post.find(params[:id])
        @post.comments_order = params[:order] if params[:order]
        render json: @post,
               include: { comments: [user: [:username], comments: :comments],
                          user: [:nickname],
                          tags: [:name] },
               status: :ok
      end

      def create
        @post = @user.posts.new(post_params)
        if params[:post][:tags]
          @tags = create_new_tags(params[:post][:tags])
          @post.tags = @tags
        end
        if @post.save
          render json: @post,
                 status: :ok
        else
          render json: @post.errors.full_messages,
                 status: :unprocessable_entity
        end
      end

      def search
        @posts = PostFinder.new(whitelisted_params).search

        render_json
      end

      def upvote
        @post = Post.find(params[:post_id])
        messages = UsersVote.new(@user, @post).upvote

        render json: { messages: messages },
               status: :ok
      end

      def downvote
        @post = Post.find(params[:post_id])
        messages = UsersVote.new(@user, @post).downvote

        render json: { messages: messages },
               status: :ok
      end

      def destroy
        @post = Post.find(params[:id])
        @post.destroy
        render json: { messages: 'Post deleted' },
               status: :ok
      end

      private

      def post_params
        params.require(:post).permit(:title, :text, :community_id, files: [])
      end

      def create_new_tags(tags)
        tags.split(' ').map! { |tag| Tag.find_or_initialize_by(name: tag) }
      end

      def whitelisted_params
        params.permit(:search_data, :tags, :user_id,
                      :start_date, :end_date,
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
