FactoryBot.define do
  factory :comment do
    sequence(:text) { |n| "text-#{n}" }
    user

    factory :comment_with_comments do
      transient do
        comments_count 3
      end

      after(:create) do |comment, evaluator|
        create_list(:comment, evaluator.comments_count, commentable: comment)
      end
    end
  end
end
