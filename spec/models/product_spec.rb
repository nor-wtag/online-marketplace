require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_presence_of(:stock) }
    it { should validate_numericality_of(:stock).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:reviews) }
    it { should have_many(:order_items) }
    it { should have_many(:category_products) }
    it { should have_many(:categories).through(:category_products) }
  end
end




# require 'rails_helper'

# RSpec.describe Product, type: :model do
#   let(:user) { User.create!(username: 'testuser',
#                             email: 'test@example.com',
#                             password: 'password123',
#                             phone: '1234567890',
#                             role: 'buyer') }
#   let(:valid_attributes) {
#     {
#       title: 'Test Product',
#       description: 'This is a test product description.',
#       price: 29.99,
#       stock: 10,
#       user_id: user.id
#     }
#   }

#   describe "valid products" do
#     it "is valid with valid attributes" do
#       product = Product.new(valid_attributes)
#       expect(product).to be_valid
#     end

#     it "is not valid without a title" do
#       product = Product.new(valid_attributes.merge(title: nil))
#       expect(product).not_to be_valid
#       expect(product.errors[:title]).to include("can't be blank")
#     end

#     it "is not valid without a description" do
#       product = Product.new(valid_attributes.merge(description: nil))
#       expect(product).not_to be_valid
#       expect(product.errors[:description]).to include("can't be blank")
#     end

#     it "is not valid without a price" do
#       product = Product.new(valid_attributes.merge(price: nil))
#       expect(product).not_to be_valid
#       expect(product.errors[:price]).to include("can't be blank")
#     end

#     it "is not valid with a non-positive price" do
#       product = Product.new(valid_attributes.merge(price: 0))
#       expect(product).not_to be_valid
#       expect(product.errors[:price]).to include("must be greater than 0")
#     end

#     it "is not valid without a stock" do
#       product = Product.new(valid_attributes.merge(stock: nil))
#       expect(product).not_to be_valid
#       expect(product.errors[:stock]).to include("can't be blank")
#     end

#     it "is not valid with a negative stock" do
#       product = Product.new(valid_attributes.merge(stock: -1))
#       expect(product).not_to be_valid
#       expect(product.errors[:stock]).to include("must be greater than or equal to 0")
#     end

#     it "is not valid without an associated user" do
#       product = Product.new(valid_attributes.merge(user_id: nil))
#       expect(product).not_to be_valid
#       expect(product.errors[:user]).to include("must exist")
#     end
#   end

#   describe "associations" do
#     it { should belong_to(:user) }
#     it { should have_many(:reviews) }
#     it { should have_many(:order_items) }
#     it { should have_many(:category_products) }
#     it { should have_many(:categories).through(:category_products) }
#   end
# end
