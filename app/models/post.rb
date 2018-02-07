# frozen_string_literal: true

class Post < ApplicationRecord
  attr_accessor :comments_order
  acts_as_votable
  mount_uploaders :files, PostFilesUploader
  validates :title, presence: true
  belongs_to :user, counter_cache: true
  belongs_to :community, optional: true
  has_and_belongs_to_many :tags
  before_destroy :re_count_rating_user, prepend: true
  has_many :comments, as: :commentable, dependent: :destroy

  after_update :send_hot_email, if: :isHot_changed?

  private

  def send_hot_email
    UserMailer.deliver_notification_if_post_set_hot(self).deliver_later if isHot
  end

  def re_count_rating_user
    self.user.rating -= self.cached_weighted_score
    self.user.save
  end
end
