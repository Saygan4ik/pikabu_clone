# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :post
  has_many :subcomments, class_name: 'Comment', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Comment'
end
