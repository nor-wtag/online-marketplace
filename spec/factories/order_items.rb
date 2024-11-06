FactoryBot.define do
  factory :order_item do
    association :order, factory: :order
    association :product, factory: :product
    quantity { 1 }
    price { product.price * quantity }
  end
end
