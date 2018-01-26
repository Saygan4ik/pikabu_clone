# frozen_string_literal: true

include SendGrid

class UserMailer < ApplicationMailer
  def welcome_email(user)
    mail(to: user.email, subject: 'Welcome to Pikabu-clone')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end

  def notification_if_post_set_hot(post)
    @url = '' + root_path + 'posts/' + post.id
    mail(to: post.user.email,
         subject: 'Your post has received the status of hot')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
