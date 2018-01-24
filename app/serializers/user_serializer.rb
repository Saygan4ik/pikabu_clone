# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :nickname
  has_many :posts
  has_many :communities
end
