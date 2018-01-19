module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user, on: :create

      def show
        @post = Post.find_by(id: params[:id])
        if @post.nil?
          render json: { messages: 'Post is not found' },
                 status: :not_found
        else
          render json: @post,
                 status: :ok
        end
      end

      def create
        @post = @user.posts.new(post_params)
        if @post.save
          if params[:post][:tags]
            @tags = create_new_tags(params[:post][:tags])
            @post.tags = @tags
          end
          render json: @post,
                 status: :ok
        else
          render json: @post.errors.full_messages,
                 status: :unprocessable_entity
        end
      end

      private

      def post_params
        params.require(:post).permit(:title, :text, files: [])
      end

      def create_new_tags(tags)
        tags.split(' ').map! { |tag| Tag.find_or_create_by(name: tag) }
      end
    end
  end
end
