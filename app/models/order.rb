class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User', foreign_key: 'user_id'
  has_many :order_items, dependent: :nullify
  has_many :products, through: :order_items
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending completed] }

  before_destroy :nullify_order_items

  def update_order_status!
    # order_items.where(availibility: 'unavailable').update_all(status: 'received')
    if order_items.all? { |item| item.status == 'received' || item.availibility == 'unavailable' }
      update!(status: 'completed')
    else
      # Keep it pending if not all items are finalized
      update!(status: 'pending')
    end
  end

  def recalculate_total_price
    total_price = order_items.where(availibility: 'available').sum { |item| item.price * item.quantity }
    update(total_price: total_price.round(2))
  end

  private
  def nullify_order_items
    order_items.update_all(order_id: nil)
  end
end
