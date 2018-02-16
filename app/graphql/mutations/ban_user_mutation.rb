# frozen_string_literal:true

BanUserMutation = GraphQL::Relay::Mutation.define do
  name 'BanUser'

  input_field :user_id, !types.Int
  input_field :ban_time, !types.Int

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]
    raise Exceptions::Forbidden unless ctx[:current_user].admin?

    user = User.find(inputs[:user_id])
    timeout_ban = Time.current.to_i + inputs[:ban_time].to_i
    timeout_ban = Time.at(timeout_ban).to_datetime
    user.update(isBanned: true, timeoutBan: timeout_ban)

    { message: 'User banned' }
  }
end
