# frozen_string_literal: true

class Comment < ApplicationRecord
  acts_as_votable
  mount_uploader :image, CommentImageUploader
  belongs_to :top_comment, optional: true
  belongs_to :user, counter_cache: true
  belongs_to :commentable, polymorphic: true
  before_destroy :re_count_rating_user, prepend: true
  has_many :comments, as: :commentable, dependent: :destroy

  private

  def re_count_rating_user
    user.decrement!(:rating, cached_weighted_score * 0.5)
  end
end
