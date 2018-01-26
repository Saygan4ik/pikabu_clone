# frozen_string_literal: true

# In config/initializers/rack_attack.rb
class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  throttle('req/ip', limit: 300, period: 5.minutes, &:ip)

  throttle('api', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path.include?('api')
  end

  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/auth/login' && req.post?
  end

  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/auth/login' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end
end
