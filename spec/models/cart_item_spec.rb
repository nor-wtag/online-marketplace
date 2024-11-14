require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:buyer) { User.create!(email: "buyer@example.com", password: "password", username: "buyeruser", phone: "01712345678", role: :buyer) }
  let(:cart) { Cart.create!(user: buyer) }
  let(:product) { Product.create!(user: buyer, title: "Sample Product", description: "Sample Description", price: 100.0, stock: 10) }
  let(:cart_item) { CartItem.new(cart: cart, product: product, quantity: 5) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:cart_id) }
    it { is_expected.to validate_presence_of(:product_id) }

    it 'validates quantity does not exceed product stock' do
      cart_item.quantity = 15
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include(I18n.t('cart_item.errors.quantity_stock'))
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cart) }
    it { is_expected.to belong_to(:product) }
  end
end
