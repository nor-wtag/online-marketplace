require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let(:buyer) { User.create!(email: "buyer@example.com", password: "password", username: "buyeruser", phone: "01712345678", role: :buyer) }
  let(:order) { Order.create!(user: buyer, total_price: 0, status: 'pending') }
  let(:product) { Product.create!(user: buyer, title: "Sample Product", description: "Sample Description", price: 100.0, stock: 10) }
  let(:order_item) { OrderItem.create!(order: order, product: product, quantity: 2, price: product.price) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending sent_to_delivery_company rider_assigned delivered received]) }
    it { is_expected.to validate_presence_of(:availibility) }
    it { is_expected.to validate_inclusion_of(:availibility).in_array(%w[available unavailable]) }
  end

  describe '#set_default_status' do
    it 'sets default status and availibility if they are nil' do
      new_order_item = OrderItem.new
      expect(new_order_item.status).to eq('pending')
      expect(new_order_item.availibility).to eq('available')
    end
  end

  describe '#soft_delete' do
    it 'marks the item as unavailable and updates the order total price' do
      order_item.soft_delete
      expect(order_item.reload.availibility).to eq('unavailable')
      expect(order.total_price).to eq(0)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:product).optional }
    it { is_expected.to belong_to(:rider).class_name('User').optional }
  end
end
