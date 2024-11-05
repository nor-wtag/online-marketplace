class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  validates :user_id, presence: true
  validate :buyer_only

  def total_price
    cart_items.includes(:product).sum { |item| item.product.price * item.quantity }
  end

  private

  def buyer_only
    errors.add(:user, 'can only have a cart if they are a buyer') unless user&.buyer?
  end
end
