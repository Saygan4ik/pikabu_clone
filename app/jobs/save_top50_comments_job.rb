require_dependency 'app/services/comment_finder'

class SaveTop50CommentsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    start_date = (Time.current - 1.day).beginning_of_day
    end_date = start_date.end_of_day
    @comments = CommentFinder.new(start_date: start_date,
                                  end_date: end_date).find_top50
    @comments.each do |comment|
      TopComment.create(date: start_date,
                        comment_id: comment.id,
                        rating: comment.cached_votes_score)
    end
  end
end
