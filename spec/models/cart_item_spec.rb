require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:buyer) { create(:user, role: :buyer) }
  let(:seller) { create(:user, role: :seller) }
  let(:cart) { create(:cart, user: buyer) }
  let(:product) { create(:product, seller: seller) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 5) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:cart_id) }
    it { is_expected.to validate_presence_of(:product_id) }

    it 'validates quantity does not exceed product stock' do
      cart_item.quantity = 15
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include(I18n.t('cart_item.errors.quantity_stock'))
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cart) }
    it { is_expected.to belong_to(:product) }
  end
end
