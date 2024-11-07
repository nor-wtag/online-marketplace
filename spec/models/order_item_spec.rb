require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations for quantity and price in OrderItem model' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations with order and product in OrderItem model' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end
end
