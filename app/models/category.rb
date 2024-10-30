class Category < ApplicationRecord
  has_and_belongs_to_many :products

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
