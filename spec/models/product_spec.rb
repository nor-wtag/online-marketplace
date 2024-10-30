require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { User.create(email: "test@example.com", password: "password") }

  let(:product) { Product.new(user: user, title: "Sample Title", description: "Sample Description", price: 100.0, stock: 5) }

  describe 'validations for title, description, price, and stock attributes in Product model' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:stock) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_numericality_of(:stock).is_greater_than_or_equal_to(0) }

    it "is invalid without a title" do
      product.title = nil
      expect(product).to_not be_valid
      expect(product.errors[:title]).to include("can't be blank")
    end

    it "is invalid without a description" do
      product.description = nil
      expect(product).to_not be_valid
      expect(product.errors[:description]).to include("can't be blank")
    end

    it "is invalid without a price" do
      product.price = nil
      expect(product).to_not be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it "is invalid with a price less than or equal to 0" do
      product.price = 0
      expect(product).to_not be_valid
      expect(product.errors[:price]).to include("must be greater than 0")
    end

    it "is invalid without stock" do
      product.stock = nil
      expect(product).to_not be_valid
      expect(product.errors[:stock]).to include("can't be blank")
    end

    it "is invalid with stock less than 0" do
      product.stock = -1
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
  end

  describe "Products association with category for many-to-many relationship" do
    it "can be associated with a category" do
      category = Category.create(name: "Electronics", description: "All electronic items")
      product.categories << category
      expect(product.categories).to include(category)
    end
  end
end
