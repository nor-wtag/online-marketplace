FactoryBot.define do
  factory :order do
    association :buyer, factory: :user, role: :buyer
    total_price { 100.0 }
    status { "pending" }
    verification_code { SecureRandom.hex(8) }

    trait :completed do
      status { "completed" }
    end

    trait :canceled do
      status { "canceled" }
    end
  end
end
