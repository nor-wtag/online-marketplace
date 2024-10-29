require 'rails_helper'


RSpec.describe Product, type: :model do
  let(:user) { User.create(email: "test@example.com", password: "password") }

  describe 'validations for title, description, price, and stock attributes in Product model' do
    it "validates presence of title" do
      product = Product.new(user: user, description: "Sample Description", price: 100.0, stock: 5)
      product.title = nil
      expect(product).to_not be_valid
      expect(product.errors[:title]).to include("can't be blank")
    end

    it 'validates presence of description' do
      product = Product.new(user: user, title: "Sample Title", price: 100.0, stock: 5)
      product.description = nil
      expect(product).to_not be_valid
      expect(product.errors[:description]).to include("can't be blank")
    end

    it 'validates presence of price"' do
      product = Product.new(user: user, title: "Sample Title", description: "Sample Description", stock: 5)
      product.price = nil
      expect(product).to_not be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it "validates numericality of price" do
      product = Product.new(user: user, title: "Sample Title", description: "Sample Description", price: 0, stock: 5)
      expect(product).to_not be_valid
      expect(product.errors[:price]).to include("must be greater than 0")
    end

    it "validates presence of stock" do
      product = Product.new(user: user, title: "Sample Title", description: "Sample Description", price: 100.0)
      product.stock = nil
      expect(product).to_not be_valid
      expect(product.errors[:stock]).to include("can't be blank")
    end

    it "validates numericality of stock" do
      product = Product.new(user: user, title: "Sample Title", description: "Sample Description", price: 100.0, stock: -1)
      expect(product).to_not be_valid
      expect(product.errors[:stock]).to include("must be greater than or equal to 0")
    end
  end

  describe "associations to user, review, categories, order items, cart_items, carts and orders" do
    it { should belong_to(:user) }
    it { should have_many(:reviews) }
    it { should have_many(:order_items) }
    it { should have_many(:cart_items) }
    it { should have_many(:carts).through(:cart_items) }
    it { should have_many(:orders).through(:order_items) }
    it { should have_and_belongs_to_many(:categories) }
  end
end
