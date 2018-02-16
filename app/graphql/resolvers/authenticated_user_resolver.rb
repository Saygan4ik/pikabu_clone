# frozen_string_literal:true

module Resolvers
  class AuthenticatedUserResolver
    def call(obj, args, ctx)
      raise Exceptions::Unauthorized unless ctx[:current_user]
      execute(obj, args, ctx)
    end
  end
end
