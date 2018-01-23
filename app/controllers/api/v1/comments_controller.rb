# frozen_string_literal: true

require_dependency 'app/services/users_vote'

module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user, only: [:create, :upvote, :downvote]

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

      def upvote
        @comment = Comment.find(params[:comment_id])
        @messages = UsersVote.new(@user, @comment).upvote

        render json: { messages: @messages },
               status: :ok
      end

      def downvote
        @comment = Comment.find(params[:comment_id])
        @messages = UsersVote.new(@user, @comment).downvote

        render json: { messages: @messages },
               status: :ok
      end

      private

      def comment_params
        params.require(:comment).permit(:text, :image, :parent_id, :post_id)
      end
    end
  end
end
