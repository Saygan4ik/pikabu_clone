# frozen_string_literal: true

class Post < ApplicationRecord
  attr_accessor :comments_order
  acts_as_votable
  searchkick searchable: [:title], word_start: [:title], callbacks: :async
  mount_uploaders :files, PostFilesUploader
  validates :title, presence: true
  belongs_to :user, counter_cache: true
  belongs_to :community, optional: true
  has_and_belongs_to_many :tags
  before_destroy :re_count_rating_user, prepend: true
  has_many :comments, as: :commentable, dependent: :destroy

  after_update :send_hot_email, if: :saved_change_to_isHot?

  def search_data
    {
      title: title,
      rating: cached_weighted_score,
      created_at: created_at.to_i,
      isHot: isHot,
      user_id: user_id,
      community_id: community_id,
      tag_ids: tag_ids
    }
  end

  private

  def send_hot_email
    UserMailer.deliver_notification_if_post_set_hot(self).deliver_later if isHot
  end

  def re_count_rating_user
    user.decrement!(:rating, cached_weighted_score)
  end
end
