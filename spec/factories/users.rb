FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "testuser#{n}@example.com" }
    phone { "01712345678" }
    password { "password" }
    password_confirmation { "password" }

    role { :buyer }
  end
end
