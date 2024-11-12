require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:buyer) { User.create!(email: "buyer@example.com", password: "password", username: "buyeruser", phone: "01712345678", role: :buyer) }
  let!(:cart) { Cart.create!(user: buyer) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }

    it 'allows only buyer to have a cart' do
      cart.user.role = :seller
      expect(cart).not_to be_valid
      expect(cart.errors[:user]).to include('can only have a cart if they are a buyer')
    end
  end

  describe '#total_price' do
    let(:product) { Product.create!(user: buyer, title: "Sample Product", description: "Sample Description", price: 100.0, stock: 10) }
    let!(:cart_item) { CartItem.create!(cart: cart, product: product, quantity: 2) }

    it 'calculates the total price of items in the cart' do
      expect(cart.total_price).to eq(200.0)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:cart_items) }
  end
end
