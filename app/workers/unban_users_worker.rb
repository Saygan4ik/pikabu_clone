# frozen_string_literal: true

class UnbanUsersWorker
  include Sidekiq::Worker

  def perform(*_args)
    @users = User.where(isBanned: true)
    @users.each do |user|
      user.update!(isBanned: false, timeoutBan: nil) if Time.current > user.timeoutBan1
    end
  end
end
