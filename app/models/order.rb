class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User", foreign_key: "user_id"
  has_many :order_items, dependent: :destroy
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
end
