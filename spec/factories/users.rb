FactoryBot.define do
  factory :user do
    username { "testuser" }
    email { "testuser@example.com" }
    phone { "01711111111" }
    role { :buyer }
    password { "password" }
    password_confirmation { "password" }
  end
end
