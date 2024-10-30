require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations for total_price and status in Order model' do
    it { should validate_presence_of(:total_price) }
    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:status) }
  end

  describe 'associations with user and order_items in Order model' do
    it { should belong_to(:user) }
    it { should have_many(:order_items) }
  end
end
