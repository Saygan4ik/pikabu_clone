# frozen_string_literal: true

class CommentSerializer < ActiveModel::Serializer
  attributes :text, :image, :created_at, :id, :cached_weighted_score
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :comments, as: :commentable
end
