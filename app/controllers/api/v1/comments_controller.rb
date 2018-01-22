module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user, only: :create

      def create
        @comment = @user.comments.new(comment_params)
        if @comment.save
          render json: @comment,
                 status: :ok
        else
          render json: @comment.errors.full_messages,
                 status: :unprocessable_entity
        end
      end

      private

      def comment_params
        params.require(:comment).permit(:text, :image, :parent_id, :post_id)
      end
    end
  end
end
