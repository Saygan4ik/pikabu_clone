class CommentSerializer < ActiveModel::Serializer
  attributes :text, :image, :created_at, :id
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :comments, as: :commentable
end
