# frozen_string_literal:true

UserType = GraphQL::ObjectType.define do
  name 'User'

  field :nickname, types.String
  field :created_at, types.String
  field :rating, types.Int
  field :posts_count, types.Int
  field :comments_count, types.Int
  field :isBanned, types.Boolean
  field :timeoutBan, types.String
  field :posts, PaginatedPostsType do
    argument :order, types.String
    argument :page, types.Int, default_value: 1
    resolve lambda { |obj, args, _ctx|
      posts = if args[:order] == 'time'
                obj.posts.order(created_at: :desc).page(args[:page])
              else
                obj.posts.order(cached_weighted_score: :desc).page(args[:page])
              end
      meta = Resolvers::MetaSettingResolver.new(posts).setting_meta
      OpenStruct.new(posts: posts, meta: meta)
    }
  end
end
