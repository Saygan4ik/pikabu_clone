# frozen_string_literal:true

module Resolvers
  class PostFinderResolver
    def call(_obj, args, _ctx)
      posts = case args[:type]
              when 'hot'
                PostFinder.new(args).index_hot
              when 'best'
                PostFinder.new(args).index_best
              when 'recent'
                PostFinder.new(args).index_new
              when 'search'
                PostFinder.new(args).search
              else
                raise Exceptions::BadRequest, "unexpected type - #{args[:type]}"
              end

      meta = Resolvers::MetaSettingResolver.new(posts).setting_meta
      OpenStruct.new(posts: posts, meta: meta)
    end
  end
end
