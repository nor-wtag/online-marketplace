require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:rider) { create(:user, role: 'rider') }
  let(:product) { create(:product, user: seller) }
  let(:category) { create(:category) }
  let(:buyer_review) { create(:review, user: buyer, product: product) }
  let(:order) { create(:order, user: buyer) }
  let(:order_item) { create(:order_item, order: order, product: product) }
  let(:cart) { create(:cart, user: buyer) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product) }

  context "when the user is an admin" do
    subject(:ability) { Ability.new(admin) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context "when the user is a seller" do
    subject(:ability) { Ability.new(seller) }

    it { is_expected.to be_able_to(:create, Product) }
    it { is_expected.to be_able_to(:read, Product) }
    it { is_expected.to be_able_to(:update, product) }
    it { is_expected.to be_able_to(:destroy, product) }
    it { is_expected.to be_able_to(:delete, product) }

    it { is_expected.to be_able_to(:read, Category) }
    it { is_expected.not_to be_able_to(:create, Category) }

    it { is_expected.to be_able_to(:read, Review) }
    it { is_expected.not_to be_able_to(:create, Review) }
    it { is_expected.not_to be_able_to(:update, buyer_review) }
    it { is_expected.not_to be_able_to(:destroy, buyer_review) }

    it { is_expected.to be_able_to(:read, Order, order_items: { product: { user_id: seller.id } }) }
    it { is_expected.not_to be_able_to(:update, Order, order_items: { product: { user_id: buyer.id } }) }

    it { is_expected.to be_able_to(:read, OrderItem, order: { order_items: { product: { user_id: seller.id } } }) }
    it { is_expected.to be_able_to(:update_status, order_item) if order_item.product.user == seller }
    it { is_expected.not_to be_able_to(:update, order_item) if order_item.product.user != seller }

    it { is_expected.to be_able_to(:read, seller) }
    it { is_expected.to be_able_to(:update, seller) }
    it { is_expected.to be_able_to(:destroy, seller) }
  end

  context "when the user is a buyer" do
    subject(:ability) { Ability.new(buyer) }

    it { is_expected.to be_able_to(:read, Product) }
    it { is_expected.to be_able_to(:read, Category) }
    it { is_expected.not_to be_able_to(:create, Product) }
    it { is_expected.not_to be_able_to(:destroy, product) }

    it { is_expected.to be_able_to(:create, Review) }
    it { is_expected.to be_able_to(:read, Review) }
    it { is_expected.to be_able_to(:update, buyer_review) }
    it { is_expected.to be_able_to(:destroy, buyer_review) }
    it { is_expected.to be_able_to(:delete, buyer_review) }
    it { is_expected.not_to be_able_to(:update, create(:review, user: seller, product: product)) }

    it { is_expected.to be_able_to(:create, Cart) }
    it { is_expected.to be_able_to(:read, cart) }
    it { is_expected.to be_able_to(:update, cart) }
    it { is_expected.to be_able_to(:destroy, cart) }

    it { is_expected.to be_able_to(:create, CartItem, cart: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:read, CartItem, cart: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:update, CartItem, cart: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:destroy, CartItem, cart: { user_id: buyer.id }) }

    it { is_expected.to be_able_to(:create, Order) }
    it { is_expected.to be_able_to(:read, Order, user_id: buyer.id) }
    it { is_expected.to be_able_to(:update, Order, user_id: buyer.id) }
    it { is_expected.to be_able_to(:cancel, Order, user_id: buyer.id) }

    it { is_expected.to be_able_to(:create, OrderItem) }
    it { is_expected.to be_able_to(:read, OrderItem, order: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:update, OrderItem, order: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:destroy, OrderItem, order: { user_id: buyer.id }) }
    it { is_expected.to be_able_to(:update_status, OrderItem.new(order: order, status: 'delivered'), status: 'delivered') if order.user == buyer }

    it { is_expected.to be_able_to(:read, buyer) }
    it { is_expected.to be_able_to(:update, buyer) }
    it { is_expected.to be_able_to(:destroy, buyer) }
  end

  context "when the user is a rider" do
    subject(:ability) { Ability.new(rider) }

    it { is_expected.to be_able_to(:read, rider) }
    it { is_expected.to be_able_to(:update, rider) }
    it { is_expected.to be_able_to(:destroy, rider) }

    it { is_expected.to be_able_to(:read, Order, order_items: { rider_id: rider.id }) }
    it { is_expected.not_to be_able_to(:create, Order) }

    it { is_expected.to be_able_to(:read, OrderItem, rider_id: rider.id) }
    it { is_expected.to be_able_to(:update, OrderItem, rider_id: rider.id) }
    it { is_expected.to be_able_to(:update_status, OrderItem.new(rider_id: rider.id, status: 'rider_assigned'), status: 'rider_assigned') }
  end
end
