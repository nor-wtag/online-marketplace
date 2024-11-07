class Product < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_and_belongs_to_many :categories
  has_many :carts, through: :cart_items
  has_many :orders, through: :order_items

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
