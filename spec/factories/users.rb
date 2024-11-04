FactoryBot.define do
  factory :user do
    username { "testuser" }
    email { "test@example.com" }
    password { "password" }
    password_confirmation { "password" }
    role { :buyer }
    phone { "01712345678" }
  end
end
