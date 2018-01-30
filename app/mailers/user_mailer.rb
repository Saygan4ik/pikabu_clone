# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user)
    mail(to: user.email, subject: 'Welcome to Pikabu-clone')
  end

  def notification_if_post_set_hot(post)
    @url = api_v1_post_url(post)
    mail(to: post.user.email,
         subject: 'Your post has received the status of hot')
  end
end
