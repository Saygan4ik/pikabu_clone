class PostSerializer < ActiveModel::Serializer
  attributes :title, :text, :files
  belongs_to :user
  has_many :tags
  belongs_to :community
end
