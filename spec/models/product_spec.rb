require 'rails_helper'

RSpec.describe Product, type: :model do
  let!(:user) { User.create!(email: "test@example.com", password: "password", username: "testuser", phone: "01712345678", role: :buyer) }
  let!(:product) { Product.create!(user: user, title: "Sample Title", description: "Sample Description", price: 100.0, stock: 5) }
  let!(:order) { Order.create!(user: user, total_price: 100.0) }
  let!(:order_item) { OrderItem.create!(order: order, product: product, quantity: 1, price: product.price, availibility: 'available') }
  
  describe 'validations' do
    subject { product }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:stock) }
    it { is_expected.to validate_numericality_of(:stock).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:order_items) }
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:carts).through(:cart_items) }
    it { is_expected.to have_many(:orders).through(:order_items) }
    it { is_expected.to have_and_belong_to_many(:categories) }
  end

  describe "many-to-many relationship with categories" do
    it "can be associated with a category" do
      category = Category.create!(name: "Electronics", description: "All electronic items")
      product.categories << category
      expect(product.categories).to include(category)
    end
  end

  describe "before_destroy callback" do
    it "marks associated order items as unavailable and nullifies product_id" do
      product.destroy
      order_item.reload

      expect(order_item.product_id).to be_nil
      expect(order_item.availibility).to eq('unavailable')
    end
  end
end
