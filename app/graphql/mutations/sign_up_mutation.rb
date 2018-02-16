# frozen_string_literal:true

SignUpMutation = GraphQL::Relay::Mutation.define do
  name 'SignUp'

  input_field :nickname, !types.String
  input_field :email, !types.String
  input_field :password, !types.String
  input_field :password_confirmation, !types.String

  return_field :user, UserType

  resolve lambda { |_obj, inputs, _ctx|
    user = User.new(
      nickname: inputs[:nickname],
      email: inputs[:email],
      password: inputs[:password],
      password_confirmation: inputs[:password_confirmation]
    )

    raise(ActiveRecord::RecordInvalid, user.errors.full_messages.join(', ')) unless user.save
    UserMailer.welcome_email(user).deliver_later
    { user: user }
  }
end
