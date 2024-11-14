require 'rails_helper'

RSpec.describe Category, type: :model do
  let!(:user) { User.create!(email: "test@example.com", password: "password", username: "testuser", phone: "01712345678", role: :buyer) }
  let(:product) { Product.new(seller: user, title: "Sample Title", description: "Sample Description", price: 100.0, stock: 5) }
  let(:category) { Category.create!(name: "Electronics", description: "All electronic items") }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
  end

  describe "many-to-many association with products" do
    it "can be associated with a product" do
      category.products << product
      expect(category.products).to include(product)
    end
  end
end
