class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :cart_id, presence: true
  validates :product_id, presence: true
end