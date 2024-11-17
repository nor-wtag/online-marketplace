FactoryBot.define do
  factory :product do
    title { "Sample Product" }
    description { "This is a sample product description." }
    price { 10.0 }
    stock { 10 }
    association :seller, factory: :user
  end
end
