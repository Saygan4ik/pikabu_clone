# frozen_string_literal: true

UnionCommentPostType = GraphQL::UnionType.define do
  name 'UnionCommentPostType'

  possible_types [PostType, CommentType]
end
