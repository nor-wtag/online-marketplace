class Product < ApplicationRecord
  belongs_to :user
  has_many :reviews
  has_many :order_items
  has_many :category_products
  has_many :categories, through: :category_products
  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
