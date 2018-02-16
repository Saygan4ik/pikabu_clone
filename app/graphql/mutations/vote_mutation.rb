# frozen_string_literal:true

VoteMutation = GraphQL::Relay::Mutation.define do
  name 'vote'

  input_field :type, !types.String
  input_field :post_id, types.Int
  input_field :comment_id, types.Int

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]

    votable = find_votable(inputs)

    message = case inputs[:type]
              when 'like'
                UsersVote.new(ctx[:current_user], votable).upvote
              when 'dislike'
                UsersVote.new(ctx[:current_user], votable).downvote
              else
                raise Exceptions::BadRequest, "unexpected type - #{inputs[:type]}"
              end

    { message: message }
  }

  def find_votable(inputs)
    votable = Comment.find(inputs[:comment_id]) if inputs[:comment_id]
    votable = Post.find(inputs[:post_id]) if inputs[:post_id]

    raise Exceptions::BadRequest unless votable
  end
end
