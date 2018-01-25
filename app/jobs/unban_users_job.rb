class UnbanUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @users = User.where(isBanned: true)
    @users.each do |user|
      if Time.current > user.timeoutBan
        user.update(isBanned: false, timeoutBan: nil)
      end
    end
  end
end
