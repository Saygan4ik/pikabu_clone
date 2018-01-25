# frozen_string_literal: true

require_dependency 'app/services/post_finder'

class UserprofileSerializer < ActiveModel::Serializer
  attributes :userprofile

  def userprofile
    {
      nickname: object.nickname,
      created_at: object.created_at,
      rating: object.rating,
      comments_count: object.comments_count,
      posts_count: object.posts_count,
      hot_posts_count: object.posts.where(isHot: true).count,
      positive_votes: object.find_liked_items.count,
      negative_votes: object.find_disliked_items.count
    }
  end
end
