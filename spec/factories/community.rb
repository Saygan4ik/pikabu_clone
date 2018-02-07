FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "community-#{n}" }
  end
end
