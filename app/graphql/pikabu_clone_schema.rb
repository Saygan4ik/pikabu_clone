# frozen_string_literal: true

PikabuCloneSchema = GraphQL::Schema.define do
  mutation(MutationType)
  query(QueryType)
  resolve_type lambda { |_type, obj, _ctx|
    case obj
    when Post
      PostType
    when Comment
      CommentType
    else
      raise("Don't know how to get the GraphQL type of a #{obj.class.name} (#{obj.inspect})")
    end
  }
end
