# frozen_string_literal: true

class SetPostAsHotWorker
  include Sidekiq::Worker

  def perform(*_args)
    @posts = Post.where(isHot: false,
                        created_at: Time.current - 24.hours..Time.current)
    @posts.each do |post|
      next unless post.cached_votes_score >= 100
      post.update(isHot: true)
    end
  end
end
