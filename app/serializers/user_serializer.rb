# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :user_profile, :post_meta
  has_many :communities
  has_many :posts

  def posts
    if object.posts_order == 'time'
      object.posts.order(created_at: :desc).page(object.posts_page)
    else
      object.posts.order(cached_votes_score: :desc).page(object.posts_page)
    end
  end

  def post_meta
    {
      current_page: posts.current_page,
      next_page: posts.next_page,
      prev_page: posts.prev_page,
      total_pages: posts.total_pages,
      total_count: posts.total_count
    }
  end

  def user_profile
    profile = {
      nickname: object.nickname,
      created_at: object.created_at,
      rating: object.rating,
      comments_count: object.comments_count,
      posts_count: object.posts_count,
      hot_posts_count: object.posts.where(isHot: true).count,
      positive_votes: object.find_liked_items.count,
      negative_votes: object.find_disliked_items.count
    }
    if object.isBanned?
      profile[:isBanned] = object.isBanned
      profile[:timeoutBan] = object.timeoutBan
    end
    profile
  end
end
