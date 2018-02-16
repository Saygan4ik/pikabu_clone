# frozen_string_literal:true

CreatePostMutation = GraphQL::Relay::Mutation.define do
  name 'CreatePost'

  input_field :title, !types.String
  input_field :text, !types.String
  input_field :tags, types.String
  input_field :community_id, types.Int

  return_field :post, PostType

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]

    post = ctx[:current_user].posts.new(
      title: inputs[:title],
      text: inputs[:text],
      community_id: inputs[:community_id]
    )
    if inputs[:tags]
      tags = create_new_tags(inputs[:tags])
      post.tags = tags
    end

    post.files = ctx[:files] if ctx[:files]

    raise(ActiveRecord::RecordInvalid, post.errors.full_messages.join(', ')) unless post.save
    { post: post }
  }

  def create_new_tags(tags)
    tags.split(' ').map! { |tag| Tag.find_or_initialize_by(name: tag) }
  end
end
