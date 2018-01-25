# frozen_string_literal: true

class CommentFinder
  def initialize(params)
    @params = params
  end

  def find_top50
    @comments = Comment.where(created_at: @params[:start_date]..@params[:end_date])
                       .order(cached_weighted_score: :desc)
                       .limit(50)
  end
end
