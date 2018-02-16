# frozen_string_literal: true

TagType = GraphQL::ObjectType.define do
  name 'Tag'

  field :name, types.String
end
