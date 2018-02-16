# frozen_string_literal: true

PostMetaType = GraphQL::ObjectType.define do
  name 'Post_meta'

  field :current_page, types.Int
  field :next_page, types.Int
  field :prev_page, types.Int
  field :total_pages, types.Int
  field :total_count, types.Int
end
