# frozen_string_literal:true

DestroyPostMutation = GraphQL::Relay::Mutation.define do
  name 'DestroyPost'

  input_field :post_id, !types.Int

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]
    raise Exceptions::Forbidden unless ctx[:current_user].admin?

    post = Post.find(inputs[:post_id])
    post.destroy

    { message: 'Post deleted' }
  }
end
