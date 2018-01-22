# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'picabu.clone@gmail.com'
  layout 'mailer'
end
