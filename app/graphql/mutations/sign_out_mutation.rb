# frozen_string_literal:true

SignOutMutation = GraphQL::Relay::Mutation.define do
  name 'SignOut'

  return_field :message, types.String

  resolve lambda { |_obj, _inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]
    ctx[:current_user].token = nil

    raise(ActiveRecord::RecordInvalid, ctx[:current_user].errors.full_messages.join(', ')) unless ctx[:current_user].save
    ctx[:session][:token] = nil
    { message: 'Logout successfully' }
  }
end
