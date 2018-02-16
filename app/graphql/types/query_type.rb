# frozen_string_literal:true

QueryType = GraphQL::ObjectType.define do
  name 'Query'

  field :posts, PaginatedPostsType do
    argument :search_data, types.String
    argument :tags, types.String
    argument :start_date, types.String
    argument :end_date, types.String
    argument :community_id, types.Int
    argument :order, types.String
    argument :order_by, types.String
    argument :page, types.Int
    argument :per_page, types.Int
    argument :type, types.String
    description 'Get hot posts'

    resolve Resolvers::PostFinderResolver.new
  end

  field :post, PostType do
    argument :id, !types.Int
    description 'Get post by id'

    resolve ->(_obj, args, _ctx) { Post.find(args[:id]) }
  end

  field :comment, CommentType do
    argument :id, !types.Int
    description 'Get comment by id'

    resolve ->(_obj, args, _ctx) { Comment.find(args[:id]) }
  end

  field :user, UserType do
    argument :id, !types.Int
    description 'Get user by id'

    resolve ->(_obj, args, _ctx) { User.find(args[:id]) }
  end

  field :top_comment, CommentType do
    description 'Get comment by id'
    resolve lambda { |_obj, _args, _ctx|
      CommentFinder.new(start_date: Time.current - 24.hours,
                        end_date: Time.current).find_top50.first
    }
  end

  field :top50_comments, types[TopCommentType] do
    argument :date, types.String
    description 'Get top 50 comments'

    resolve Resolvers::TopCommentResolver.new
  end

  field :favorites, types[FavoriteType] do
    description 'Get the list of user favorites'
    resolve Resolvers::FavoriteResolver.new
  end

  field :favorites_contents, types[UnionCommentPostType] do
    description 'Get contents by favorites'
    argument :favorite_id, types.Int

    resolve Resolvers::FavoritesContentsResolver.new
  end

  field :communities, types[CommunityType] do
    description 'Get list of communities'
    resolve ->(_obj, _args, _ctx) { Community.all }
  end

  field :community, CommunityType do
    description 'Get community by id'
    resolve ->(_obj, args, _ctx) { Community.find(args[:id]) }
  end

  field :posts_subscriptions, PaginatedPostsType do
    description 'Get posts from subscription communities'
    resolve Resolvers::PostsSubscriptionsResolver.new
  end
end
