# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user)
    mail(to: user.email, subject: 'Welcome to Pikabu-clone')
  end
end
