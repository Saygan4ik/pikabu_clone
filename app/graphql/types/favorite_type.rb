# frozen_string_literal: true

FavoriteType = GraphQL::ObjectType.define do
  name 'Favorite'

  field :name, types.String
end
