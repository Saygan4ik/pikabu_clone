# frozen_string_literal:true

CreateCommentMutation = GraphQL::Relay::Mutation.define do
  name 'CreateComment'

  input_field :text, !types.String
  input_field :post_id, types.Int
  input_field :comment_id, types.Int

  return_field :comment, CommentType

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]

    commentable = find_commentable(inputs)

    comment = commentable.comments.new(
      text: inputs[:text],
      user: ctx[:current_user]
    )
    comment.image = ctx[:files][0] if ctx[:files]

    raise(ActiveRecord::RecordInvalid, comment.errors.full_messages.join(', ')) unless comment.save
    { comment: comment }
  }

  def find_commentable(inputs)
    commentable = Comment.find(inputs[:comment_id]) if inputs[:comment_id]
    commentable = Post.find(inputs[:post_id]) if inputs[:post_id]

    raise Exceptions::BadRequest unless commentable
  end
end
