# frozen_string_literal:true

module Resolvers
  class TopCommentResolver
    def call(_obj, args, _ctx)
      date = Time.parse(args[:date]).beginning_of_day if args[:date]
      if !date || date == Time.current.beginning_of_day
        load_top50_comments_last_day
      else
        load_top50_comments_another_day(date)
      end
    end

    private

    def load_top50_comments_last_day
      start_date ||= Time.current.beginning_of_day
      end_date = start_date.end_of_day
      top_comments = []
      comments = CommentFinder.new(start_date: start_date,
                                   end_date: end_date).find_top50
      comments.each do |comment|
        top_comments << OpenStruct.new(rating: comment.cached_weighted_score,
                                       date: comment.created_at,
                                       comment: comment)
      end
      top_comments
    end

    def load_top50_comments_another_day(date)
      top_comments = []
      comments = TopComment.where(date: date).order(rating: :desc)
      comments.each do |comment|
        top_comments << OpenStruct.new(rating: comment.rating,
                                       date: comment.date,
                                       comment: comment.comment)
      end
      top_comments
    end
  end
end
