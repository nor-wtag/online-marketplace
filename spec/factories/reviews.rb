FactoryBot.define do
  factory :review do
    rating { 4 }
    comment { "Good product!" }
    association :buyer, factory: :user
    association :product, factory: :product
  end
end
