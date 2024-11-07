class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending sent_to_delivery_company rider_assigned delivered received] }

  after_initialize :set_default_status, if: :new_record?
  def set_default_status
    self.status ||= 'pending'
  end
end
