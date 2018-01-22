module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user, on: :create

      def index
        @posts = Post.order(created_at: :desc).page(params[:page]).per(params[:per_page])
        render json: @posts,
               each_serializer: PostSerializer,
               meta: pagination_dict(@posts),
               status: :ok
      end

      def index_hot
        @start_date = Time.parse(params[:start_date]) if params[:start_date]
        @end_date = Time.parse(params[:end_date]) if params[:end_date]
        setting_order_parameters_request(params[:order], params[:order_by])
        setting_date_parameters_request(@start_date, @end_date)
        @posts = Post.where(created_at: @start_date..@end_date, isHot: true)
                   .order(@order_post)
                   .page(params[:page]).per(params[:per_page])
        render json: @posts,
               each_serializer: PostSerializer,
               meta: pagination_dict(@posts),
               status: :ok
      end

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

      private

      def post_params
        params.require(:post).permit(:title, :text, files: [])
      end

      def create_new_tags(tags)
        tags.split(' ').map! { |tag| Tag.find_or_initialize_by(name: tag) }
      end

      def setting_date_parameters_request(start_date, end_date)
        case
        when !start_date && !end_date
          @end_date = Time.now
          @start_date = @end_date - 24.hour
        when !start_date && end_date
          @start_date = '1970-01-01'
          @end_date = end_date + 24.hour - 1.second
        when start_date && !end_date
          @start_date = start_date
          @end_date = Time.now
        else
          @start_date = start_date
          @end_date = end_date + 24.hour
        end
      end

      def setting_order_parameters_request(order, order_by)
        if order == 'time'
          @order_post = 'created_at'
        else
          @order_post = 'cached_weighted_average'
        end
        if order_by == 'asc'
          @order_post << ' ASC'
        else
          @order_post << ' DESC'
        end
      end
    end
  end
end
