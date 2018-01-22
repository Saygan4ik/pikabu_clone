class CommentSerializer < ActiveModel::Serializer
  attributes :text, :image, :created_at, :id, :parent_id
  belongs_to :user
  belongs_to :parent, class_name: 'Comment'
  has_many :subcomments, class_name: 'Comment', foreign_key: 'parent_id'
end
