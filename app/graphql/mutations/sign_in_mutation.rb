# frozen_string_literal:true

SignInMutation = GraphQL::Relay::Mutation.define do
  name 'SignIp'

  input_field :email, !types.String
  input_field :password, !types.String

  return_field :token, types.String

  resolve lambda { |_obj, inputs, _ctx|
    user = User.find_by(email: inputs[:email]).try(:authenticate, inputs[:password])
    if user
      user.token = regenerate_token
      if user.save
        { token: user.token }
      else
        raise(ActiveRecord::RecordInvalid, user.errors.full_messages.join(', '))
      end
    else
      { message: 'Incorrect email or password' }
    end
  }
end

def regenerate_token
  token = SecureRandom.base58(24)
  token = SecureRandom.base58(24) while User.where(token: token).exists?
  token
end
