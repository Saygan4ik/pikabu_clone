# frozen_string_literal:true

UserUpdateMutation = GraphQL::Relay::Mutation.define do
  name 'UserUpdate'

  input_field :old_password, !types.String
  input_field :password, !types.String
  input_field :password_confirmation, !types.String

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]

    message = if ctx[:current_user].try(:authenticate, inputs[:old_password])
                if ctx[:current_user].update_attributes(password: inputs[:password],
                                                        password_confirmation: inputs[:password_confirmation])
                  'Password changed'
                else
                  raise(ActiveRecord::RecordInvalid, ctx[:current_user]
                                                       .errors.full_messages
                                                       .join(', '))
                end
              else
                'Password is not valid'
              end
    { message: message }
  }
end
