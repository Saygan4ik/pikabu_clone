FactoryBot.define do
  factory :favorite do
    sequence(:name) { |n| "name-#{n}" }
  end
end
