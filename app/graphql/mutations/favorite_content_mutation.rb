# frozen_string_literal:true

FavoriteContentMutation = GraphQL::Relay::Mutation.define do
  name 'FavoriteContent'

  input_field :action, !types.String
  input_field :post_id, types.Int
  input_field :comment_id, types.Int
  input_field :favorite_name, types.String

  return_field :message, types.String

  resolve lambda { |_obj, inputs, ctx|
    raise Exceptions::Unauthorized unless ctx[:current_user]

    content = find_content(inputs)

    message = case inputs[:action]
              when 'add'
                add_to_favorites(inputs, ctx, content)
              when 'remove'
                remove_from_favorites(inputs, ctx, content)
              else
                raise Exceptions::BadRequest, "unexpected action - #{inputs[:action]}"
              end

    { message: message }
  }

  def add_to_favorites(inputs, ctx, content)
    favorite_content = find_favorite_content(inputs, ctx, content)
    if favorite_content.empty?
      ctx[:current_user].favoritecontents.create!(content: content,
                                                  favorite_id: @favorite&.id)
      'Added to favorites'
    else
      'Has been added already'
    end
  end

  def remove_from_favorites(inputs, ctx, content)
    favorite_content = find_favorite_content(inputs, ctx, content)
    raise Exceptions::BadRequest if favorite_content.empty?
    favorite_content.destroy_all
    'Remove from favorites'
  end

  def find_favorite_content(inputs, ctx, content)
    favorite_id = inputs[:favorite_name] ? find_or_create_favorite(inputs).id : nil
    ctx[:current_user].favoritecontents.where(content: content,
                                              favorite_id: favorite_id)
  end

  def find_content(inputs)
    content = Comment.find(inputs[:comment_id]) if inputs[:comment_id]
    content = Post.find(inputs[:post_id]) if inputs[:post_id]

    raise Exceptions::BadRequest unless content

    content
  end

  def find_or_create_favorite(inputs)
    @favorite = Favorite.find_or_create_by(name: inputs[:favorite_name]) if inputs[:favorite_name]
  end
end
