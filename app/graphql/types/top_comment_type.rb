# frozen_string_literal: true

TopCommentType = GraphQL::ObjectType.define do
  name 'Top_comment'

  field :rating, types.Int
  field :date, types.String
  field :comment, CommentType
end
