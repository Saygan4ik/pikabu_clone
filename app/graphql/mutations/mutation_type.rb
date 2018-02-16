# frozen_string_literal: true

MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  field :sign_up, field: SignUpMutation.field
  field :sign_in, field: SignInMutation.field
  field :sign_out, field: SignOutMutation.field
  field :create_post, field: CreatePostMutation.field
  field :destroy_post, field: DestroyPostMutation.field
  field :create_comment, field: CreateCommentMutation.field
  field :destroy_comment, field: DestroyCommentMutation.field
  field :vote, field: VoteMutation.field
  field :favorite_content, field: FavoriteContentMutation.field
  field :subscribe_community, field: SubscribeCommunityMutation.field
  field :ban_user, field: BanUserMutation.field
  field :user_update, field: UserUpdateMutation.field
end
