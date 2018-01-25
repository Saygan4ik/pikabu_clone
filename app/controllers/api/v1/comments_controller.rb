# frozen_string_literal: true

require_dependency 'app/services/users_vote'
require_dependency 'app/services/top_comments'

module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user, only: %i[create upvote downvote]
      before_action :find_commentable

      def create
        @comment = @commentable.comments.new(comment_params)
        @comment[:user_id] = @user.id
        if @comment.save
          render json: @comment,
                 status: :ok
        else
          render json: @comment.errors.full_messages,
                 status: :unprocessable_entity
        end
      end

      def show
        @comment = Comment.find(params[:id])
        render json: @comment,
               status: :ok
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

      def top_comment
        end_date = Time.current
        start_date = end_date - 24.hours
        @comment = TopComments.new([start_date, end_date]).find_top50.first
        render json: @comment,
               status: :ok
      end

      def top_50_comments
        start_date = Time.parse(params[:date]).beginning_of_day if params[:date]
        if !start_date || start_date == Time.current.beginning_of_day
          start_date ||= Time.current.beginning_of_day
          end_date = start_date.end_of_day
          @comments = TopComments.new([start_date, end_date]).find_top50
        else
          #@comments = DB top_comments where date = start_day
        end
      end

      private

      def comment_params
        params.require(:comment).permit(:text, :image)
      end

      def find_commentable
        @commentable = Comment.find(params[:comment_id]) if params[:comment_id]
        @commentable = Post.find(params[:post_id]) if params[:post_id]

        unless @commentable
          render json: { messages: 'Bad request' },
                 status: :bad_request
        end
      end
    end
  end
end
