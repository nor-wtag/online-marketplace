class Product < ApplicationRecord
  before_destroy :mark_order_items_unavailable

  belongs_to :seller, class_name: 'User', foreign_key: 'user_id'
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items
  has_and_belongs_to_many :categories
  has_many :carts, through: :cart_items
  has_many :orders, through: :order_items
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :image_validation

  def image_validation
    return unless image.attached?

    if !image.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add(:image, 'must be a PNG, JPG, or JPEG file')
    elsif image.blob.byte_size > 5.megabytes
      errors.add(:image, 'should be less than 5MB')
    end
  end

  def mark_order_items_unavailable
    order_items.update_all(product_id: nil, availibility: 'unavailable')
  end
end
