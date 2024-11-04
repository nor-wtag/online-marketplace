FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Sample Category #{n}" }
    description { "This is a sample category description." }
  end
end
