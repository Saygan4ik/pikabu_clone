# frozen_string_literal:true

DestroyCommentMutation = GraphQL::Relay::Mutation.define do
  name 'DestroyComment'

  input_field :comment_id, !types.Int

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]
    raise Exceptions::Forbidden unless ctx[:current_user].admin?

    comment = Comment.find(inputs[:comment_id])
    comment.destroy

    { message: 'Comment deleted' }
  }
end
