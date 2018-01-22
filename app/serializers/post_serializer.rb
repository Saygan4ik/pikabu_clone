# frozen_string_literal: true

class PostSerializer < ActiveModel::Serializer
  attributes :title, :text, :files, :created_at
  belongs_to :user
  has_many :tags
  belongs_to :community
end
