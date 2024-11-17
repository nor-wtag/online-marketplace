require 'rails_helper'

RSpec.describe OrderItemsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:rider) { create(:user, role: 'rider') }
  let(:admin) { create(:user, role: 'admin') }
  let(:product) { create(:product, seller: seller, stock: 10, price: 100) }
  let(:order) { create(:order, buyer: buyer, total_price: 250, status: 'pending') }
  let(:order_item) { create(:order_item, order: order, product: product, quantity: 2, price: product.price) }

  describe "PATCH #update_status" do
    context "as an admin" do
      before { sign_in admin }

      it "assigns a rider and updates status to 'rider_assigned'" do
        patch :update_status, params: { order_id: order.id, id: order_item.id, rider_id: rider.id, status: 'rider_assigned' }
        expect(order_item.reload.status).to eq('rider_assigned')
        expect(order_item.rider_id).to eq(rider.id)
        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq(I18n.t('order_items.rider_assigned'))
      end
    end

    context "as a seller updating their own product's order item" do
      before { sign_in seller }

      it "updates status to 'sent_to_delivery_company'" do
        patch :update_status, params: { order_id: order.id, id: order_item.id, status: 'sent_to_delivery_company' }
        expect(order_item.reload.status).to eq('sent_to_delivery_company')
        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq(I18n.t('order_items.status_updated'))
      end

      it "does not allow invalid status updates" do
        patch :update_status, params: { order_id: order.id, id: order_item.id, status: 'completed' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('order_items.unauthorized_update'))
      end
    end

    context "as a buyer confirming receipt" do
      before do
        sign_in buyer
        order_item.update(status: 'delivered')
      end

      it "updates status to 'received'" do
        patch :update_status, params: { order_id: order.id, id: order_item.id, status: 'received' }
        expect(order_item.reload.status).to eq('received')
        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq(I18n.t('order_items.received'))
      end
    end

    context "unauthorized update attempts" do
      before { sign_in buyer }

      it "prevents unauthorized status updates" do
        patch :update_status, params: { order_id: order.id, id: order_item.id, status: 'sent_to_delivery_company' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('order_items.unauthorized_update'))
      end
    end
  end
end
