class Category < ApplicationRecord
  has_and_belongs_to_many :products

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
