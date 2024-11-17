require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:buyer) { create(:user, role: :buyer) }
  let(:order) { create(:order, buyer: buyer) }
  let(:seller) { create(:user, role: :seller) }
  let(:product) { create(:product, seller: seller) }
  let!(:order_item) { create(:order_item, order: order, product: product, quantity: 2, price: product.price, status: 'pending', availibility: 'available') }
  
  describe 'validations' do
    it { is_expected.to validate_presence_of(:total_price) }
    it { is_expected.to validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending completed]) }
  end

  describe 'associations' do
    it { should belong_to(:buyer).class_name('User') }
    it { is_expected.to have_many(:order_items) }
    it { is_expected.to have_many(:products).through(:order_items) }
  end

  describe '#update_order_status!' do
    context 'when all order items are received' do
      it 'updates the status to completed' do
        order_item.update(status: 'received')
        order.update_order_status!
        expect(order.status).to eq('completed')
      end
    end

    context 'when at least one order item is not received' do
      it 'keeps the status as pending' do
        order.update_order_status!
        expect(order.status).to eq('pending')
      end
    end
  end

  describe '#recalculate_total_price' do
    it 'updates the total price based on available order items' do
      order.recalculate_total_price
      expect(order.total_price).to eq(20.0)
    end
  
    it 'excludes unavailable order items from total price' do
      order_item.update(availibility: 'unavailable')
      order.recalculate_total_price
      expect(order.total_price).to eq(0.0)
    end
  end
end
