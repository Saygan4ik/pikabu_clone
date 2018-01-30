# frozen_string_literal: true

class UnbanUsersWorker
  include Sidekiq::Worker

  def perform(*_args)
    @users = User.where(isBanned: true)
    @users.each do |user|
      if Time.current > user.timeoutBan
        user.update(isBanned: false, timeoutBan: nil)
      end
    end
  end
end
