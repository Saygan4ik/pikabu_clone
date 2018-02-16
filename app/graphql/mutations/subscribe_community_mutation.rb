# frozen_string_literal:true

SubscribeCommunityMutation = GraphQL::Relay::Mutation.define do
  name 'SubscribeCommunity'

  input_field :action, !types.String
  input_field :community_id, !types.Int

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]

    community = Community.find(inputs[:community_id])

    message = case inputs[:action]
              when 'subscribe'
                subscribe(ctx, community)
              when 'unsubscribe'
                unsubscribe(ctx, community)
              else
                raise Exceptions::BadRequest, "unexpected type - #{inputs[:type]}"
              end

    { message: message }
  }

  def subscribe(ctx, community)
    if ctx[:current_user].communities.exists?(community.id)
      'You are already subscribed'
    else
      ctx[:current_user].communities << community
      'Thank you to subscribe'
    end
  end

  def unsubscribe(ctx, community)
    if ctx[:current_user].communities.exists?(community.id)
      ctx[:current_user].communities.delete(community.id)
      'You unsubscribe from community'
    else
      'You do not belong to the community'
    end
  end
end
