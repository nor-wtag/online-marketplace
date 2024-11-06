FactoryBot.define do
  factory :cart do
    association :user, factory: :user, role: 'buyer'
  end
end
