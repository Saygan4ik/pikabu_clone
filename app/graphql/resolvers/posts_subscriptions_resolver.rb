# frozen_string_literal:true

module Resolvers
  class PostsSubscriptionsResolver < AuthenticatedUserResolver
    private

    def execute(_obj, _args, ctx)
      posts = Post.where(community_id: ctx[:current_user].community_ids)
                  .order(created_at: :desc).page

      meta = Resolvers::MetaSettingResolver.new(posts).setting_meta
      OpenStruct.new(posts: posts, meta: meta)
    end
  end
end
