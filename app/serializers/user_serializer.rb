class UserSerializer < ActiveModel::Serializer
  attributes :nickname
  has_many :posts
end
