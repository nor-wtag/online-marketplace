require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe "validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:cart_id) }
    it { should validate_presence_of(:product_id) }
  end

  describe "associations" do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end
end
