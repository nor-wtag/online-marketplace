FactoryBot.define do
  factory :product do
    title { "Sample Product" }
    description { "This is a sample product description." }
    price { 9.99 }
    stock { 10 }
    association :user
  end
end
