FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "title-#{n}" }
    sequence(:text) { |n| "text-#{n}" }
    user

    factory :post_with_comments do
      transient do
        comments_count 3
      end

      after(:create) do |post, evaluator|
        create_list(:comment, evaluator.comments_count, commentable: post)
      end
    end
  end
end
