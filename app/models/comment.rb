# frozen_string_literal: true

class Comment < ApplicationRecord
  acts_as_votable
  mount_uploader :image, CommentImageUploader
  belongs_to :user, counter_cache: true
  belongs_to :post
  has_many :subcomments, class_name: 'Comment', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Comment', optional: true
end
