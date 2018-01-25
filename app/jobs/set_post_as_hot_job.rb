# frozen_string_literal: true

class SetPostAsHotJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @posts = Post.where(created_at: Time.current - 24.hours..Time.current)
                 .where(isHot: false)
    @posts.each do |post|
      if post.cached_votes_score >= 100
        post.update(isHot: true)
        UserMailer.deliver_notification_if_post_set_hot(post).deliver_later
      end
    end
  end
end
