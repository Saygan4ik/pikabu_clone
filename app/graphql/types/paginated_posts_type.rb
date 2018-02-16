# frozen_string_literal: true

PaginatedPostsType = GraphQL::ObjectType.define do
  name 'Paginated_post'

  field :posts, types[PostType]
  field :meta, PostMetaType
end
