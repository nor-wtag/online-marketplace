FactoryBot.define do
  factory :user do
    username { 'testuser' }
    email { 'test@example.com' }
    phone { '01712345678' }
    password { 'password' }
    role { 'buyer' }
  end

  factory :invalid_user, parent: :user do
    username { '' }
    email { 'invalid-email' }
    phone { 'not_a_number' }
    password { 'short' }
    role { '' }
  end
end
