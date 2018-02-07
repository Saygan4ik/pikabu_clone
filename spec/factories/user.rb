FactoryBot.define do
  factory :user do
    sequence(:nickname) { |n| "nickname-#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password" }
  end
end
