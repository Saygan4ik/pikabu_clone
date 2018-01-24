# frozen_string_literal: true

class CommunitySerializer < ActiveModel::Serializer
  attributes :name
  has_many :users
  has_many :posts
end
