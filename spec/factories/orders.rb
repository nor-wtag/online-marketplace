FactoryBot.define do
  factory :order do
    association :user, factory: :user # Assumes you have a `user` factory
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
