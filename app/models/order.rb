class Order < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'
  has_many :order_items
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending completed] }
  
  def update_order_status!
    if order_items.all? { |item| item.status == 'received' }
      update(status: 'completed')
    else
      update(status: 'pending')
    end
  end

  def recalculate_total_price
    total_price = order_items.where(availibility: 'available').sum { |item| item.price * item.quantity }
    update(total_price: total_price)
  end
end

