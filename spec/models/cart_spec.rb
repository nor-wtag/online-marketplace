require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:buyer) { create(:user, role: :buyer) }
  let!(:cart) { create(:cart, user: buyer) }
  let(:seller) { create(:user, role: :seller) }
  let(:product) { create(:product, seller: seller) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }

    it 'allows only buyer to have a cart' do
      cart.user.role = :seller
      expect(cart).not_to be_valid
      expect(cart.errors[:user]).to include(I18n.t('cart.errors.buyer_only'))
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:cart_items) }
  end
end
