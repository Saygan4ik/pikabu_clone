# frozen_string_literal: true

class PostSerializer < ActiveModel::Serializer
  attributes :title, :text, :files, :created_at, :cached_weighted_score
  belongs_to :user
  has_many :tags
  belongs_to :community
  has_many :comments, as: :commentable

  def comments
    if object.comments_order == 'rating'
      object.comments.order(cached_weighted_score: :desc)
    else
      object.comments.order(created_at: :desc)
    end
  end
end
