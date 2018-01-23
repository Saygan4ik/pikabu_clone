class UsersVote
  def initialize(user, object)
    @user = user
    @object = object
  end

  def upvote
    if @user.liked? @object
      messages = "User is already liked this #{@object.class}"
    else
      if @user.disliked? @object
        @object.undisliked_by @user
        messages = "Remove dislike vote this #{@object.class}"
      else
        @object.liked_by @user
        messages = "#{@object.class} is liked"
      end
      if @object.class == Post
        @object.user.increment!(:rating, 1)
      else
        @object.user.increment!(:rating, 0.5)
      end
    end
    messages
  end

  def downvote
    if @user.disliked? @object
      messages = "User is already disliked this #{@object.class}"
    else
      if @user.liked? @object
        @object.unliked_by @user
        messages = "Remove like vote this #{@object.class}"
      else
        @object.disliked_by @user
        messages = "#{@object.class} is disliked"
      end
      if @object.class == Post
        @object.user.decrement!(:rating, 1)
      else
        @object.user.decrement!(:rating, 0.5)
      end
    end
    messages
  end
end
