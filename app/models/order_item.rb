class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true
  belongs_to :rider, class_name: 'User', foreign_key: 'rider_id', optional: true

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending sent_to_delivery_company rider_assigned delivered received] }
  validates :availibility, presence: true, inclusion: { in: %w[available unavailable] }

  after_initialize :set_default_status, if: :new_record?

  def set_default_status
    self.status ||= 'pending'
    self.availibility ||= 'available'
  end

  def soft_delete
    update(availibility: 'unavailable')
    order.recalculate_total_price
  end
end
