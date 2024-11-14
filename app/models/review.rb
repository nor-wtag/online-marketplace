class Review < ApplicationRecord
  belongs_to :buyer, class_name: 'User', foreign_key: 'user_id'
  belongs_to :product
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true
end
