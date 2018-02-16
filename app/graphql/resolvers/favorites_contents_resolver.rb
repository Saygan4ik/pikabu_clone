# frozen_string_literal:true

module Resolvers
  class FavoritesContentsResolver < AuthenticatedUserResolver
    private

    def execute(_obj, args, ctx)
      favorites = ctx[:current_user].favoritecontents
      favorites = favorites.where(favorite_id: args[:favorite_id]) if args[:favorite_id]
      response = []
      favorites.each do |item|
        response << item.content
      end
      response
    end
  end
end
