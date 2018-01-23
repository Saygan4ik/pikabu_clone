# frozen_string_literal: true

class PostSerializer < ActiveModel::Serializer
  attributes :title, :text, :files, :created_at, :cached_weighted_score
  belongs_to :user
  has_many :tags
  belongs_to :community
  has_many :comments
end
