FactoryBot.define do
  factory :review do
    rating { 4 }
    comment { "Good product!" }
    association :user, factory: :user
    association :product, factory: :product
  end
end
