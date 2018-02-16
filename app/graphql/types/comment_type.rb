# frozen_string_literal: true

CommentType = GraphQL::ObjectType.define do
  name 'Comment'

  field :text, types.String
  field :image, types.String
  field :user, UserType
  field :created_at, types.String
  field :cached_weighted_score, types.Int
  field :comments, types[CommentType]
  field :commentable, UnionCommentPostType do
    resolve ->(obj, _args, _ctx) { obj.commentable }
  end
end
