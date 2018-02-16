# frozen_string_literal: true

CommunityType = GraphQL::ObjectType.define do
  name 'Community'

  field :name, types.String
end
