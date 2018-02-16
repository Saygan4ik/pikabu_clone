# frozen_string_literal: true

PostType = GraphQL::ObjectType.define do
  name 'Post'

  field :title, types.String
  field :text, types.String
  field :files, types[types.String]
  field :user, UserType
  field :created_at, types.String
  field :community, CommunityType
  field :cached_weighted_score, types.Int
  field :isHot, types.Boolean
  field :tags, types[TagType]
  field :comments, types[CommentType] do
    argument :order, types.String
    resolve lambda { |obj, args, _ctx|
      if args[:order] == 'time'
        obj.comments.order(created_at: :desc)
      else
        obj.comments.order(cached_weighted_score: :desc)
      end
    }
  end
end
