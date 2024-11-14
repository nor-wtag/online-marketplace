require 'rails_helper'

RSpec.describe Product do
  let(:user) { User.create(email: "test@example.com", password: "password", username: "testuser") }
  let(:product) { Product.new(seller: user, title: "Sample Title", description: "Sample Description", price: 100.0, stock: 5) }
  
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
    it { should belong_to(:seller).class_name('User') }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:order_items).dependent(:destroy) }
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:carts).through(:cart_items) }
    it { is_expected.to have_many(:orders).through(:order_items) }
    it { is_expected.to have_and_belong_to_many(:categories) }
  end

  describe "many-to-many relationship with categories" do
    it "can be associated with a category" do
      category = Category.create(name: "Electronics", description: "All electronic items")
      product.categories << category
      expect(product.categories).to include(category)
    end
  end
end
