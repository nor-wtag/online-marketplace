require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:product) { create(:product, user: seller) }
  let(:category) { create(:category) }
  let(:buyer_review) { create(:review, user: buyer, product: product) }
  let(:seller_review) { create(:review, user: seller, product: product) }
  let(:cart) { create(:cart, user: buyer) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product) }

  context "when the user is an admin" do
    subject(:ability) { Ability.new(admin) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context "when the user is a seller" do
    subject(:ability) { Ability.new(seller) }

    # Product permissions
    it { is_expected.to be_able_to(:create, Product) }
    it { is_expected.to be_able_to(:read, Product) }
    it { is_expected.to be_able_to(:update, product) }
    it { is_expected.to be_able_to(:destroy, product) }

    # Category permissions
    it { is_expected.to be_able_to(:read, Category) }
    it { is_expected.not_to be_able_to(:create, Category) }

    # Review permissions (can read reviews for products they own)
    it { is_expected.to be_able_to(:read, Review, product: { user_id: seller.id }) }
    it { is_expected.not_to be_able_to(:create, Review) }
    it { is_expected.not_to be_able_to(:update, buyer_review) }
    it { is_expected.not_to be_able_to(:destroy, buyer_review) }

    # Cart and CartItem permissions (should not have any for seller role)
    it { is_expected.not_to be_able_to(:read, Cart) }
    it { is_expected.not_to be_able_to(:create, Cart) }
    it { is_expected.not_to be_able_to(:create, CartItem) }

    # User model permissions
    it { is_expected.to be_able_to(:read, seller) }
    it { is_expected.to be_able_to(:update, seller) }
    it { is_expected.to be_able_to(:destroy, seller) }
    it { is_expected.not_to be_able_to(:manage, buyer) }
    it { is_expected.not_to be_able_to(:manage, admin) }
  end

  context "when the user is a buyer" do
    subject(:ability) { Ability.new(buyer) }

    # Product and Category permissions
    it { is_expected.to be_able_to(:read, Product) }
    it { is_expected.to be_able_to(:read, Category) }
    it { is_expected.not_to be_able_to(:create, Product) }
    it { is_expected.not_to be_able_to(:destroy, product) }

    # Review permissions
    it { is_expected.to be_able_to(:create, Review) }
    it { is_expected.to be_able_to(:read, Review) }
    it { is_expected.to be_able_to(:update, buyer_review) }
    it { is_expected.to be_able_to(:destroy, buyer_review) }
    it { is_expected.not_to be_able_to(:update, seller_review) }
    it { is_expected.not_to be_able_to(:destroy, seller_review) }

    # Cart permissions
    it { is_expected.to be_able_to(:create, Cart) }
    it { is_expected.to be_able_to(:read, cart) }
    it { is_expected.to be_able_to(:update, cart) }
    it { is_expected.to be_able_to(:destroy, cart) }

    # CartItem permissions
    it { is_expected.to be_able_to(:create, CartItem, cart: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:read, CartItem, cart: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:update, CartItem, cart: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:destroy, CartItem, cart: { user_id: buyer.id }) }

    # User model permissions
    it { is_expected.to be_able_to(:read, buyer) }
    it { is_expected.to be_able_to(:update, buyer) }
    it { is_expected.to be_able_to(:destroy, buyer) }
    it { is_expected.not_to be_able_to(:manage, seller) }
    it { is_expected.not_to be_able_to(:manage, admin) }
  end
end
