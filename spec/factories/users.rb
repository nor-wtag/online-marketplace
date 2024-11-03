# FactoryBot.define do
#   factory :user do
#     username { 'testuser' }
#     email { 'test@example.com' }
#     phone { '01712345678' }
#     password { 'password' }
#     role { 'buyer' }
#   end

#   factory :invalid_user, parent: :user do
#     username { '' }
#     email { 'invalid-email' }
#     phone { 'not_a_number' }
#     password { 'short' }
#     role { '' }
#   end
# end
# 
FactoryBot.define do
factory :user do
  username { "testuser" }
  email { "testuser@example.com" }
  phone { "01712345678" }
  role { "buyer" }
  password { "password123" }
  password_confirmation { "password123" }
end
end
