require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user) { User.create(email: "test@example.com", password: "password") }
  let(:product) { Product.new(user: user, title: "Sample Title", description: "Sample Description", price: 100.0, stock: 5) }
  let(:category) { Category.new(name: "Electronics", description: "All electronic items") }

  describe 'validations for name and description in Category model' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe "Category has a many-to-many association with product" do
    it "can be associated with a product" do 
      category.products << product
      expect(category.products).to include(product)
    end
  end
end
