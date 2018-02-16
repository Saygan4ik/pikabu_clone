# frozen_string_literal:true

module Resolvers
  class FavoriteResolver < AuthenticatedUserResolver
    private

    def execute(_obj, _args, ctx)
      ctx[:current_user].favorites.uniq
    end
  end
end
