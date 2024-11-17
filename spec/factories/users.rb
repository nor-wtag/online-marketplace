FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "testuser#{n}@example.com" }
    phone { "01712345678" }
    password { "password" }
    password_confirmation { "password" }

    role { :buyer }
    trait :seller do
      role { :seller }
    end

    trait :admin do
      role { :admin }
    end

    trait :rider do
      role { :rider }
    end
  end
end
