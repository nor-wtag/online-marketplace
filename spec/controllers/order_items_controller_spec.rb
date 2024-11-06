require 'rails_helper'

RSpec.describe OrderItemsController, type: :controller do
  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:product) { create(:product, user: seller) }
  let(:order) { create(:order, user: buyer, total_price: 100, status: "pending") }
  let(:completed_order) { create(:order, :completed) }
  let(:canceled_order) { create(:order, :canceled) }
  let!(:order_item) { create(:order_item, order: order, product: product, quantity: 2, price: 50) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #show all the product added to their order" do
    context "as a buyer" do
      before { sign_in buyer }

      it "displays the order item details for the buyer" do
        get :show, params: { id: order_item.id }
        expect(response).to render_template(:show)
        expect(assigns(:order_item)).to eq(order_item)
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "does not allow the seller to view order item details" do
        get :show, params: { id: order_item.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "PATCH #update the order" do
    context "as a buyer" do
      before { sign_in buyer }

      it "updates the order item quantity" do
        patch :update, params: { id: order_item.id, order_item: { quantity: 3 } }
        expect(response).to redirect_to(order_path(order))
        expect(order_item.reload.quantity).to eq(3)
        expect(flash[:notice]).to eq("Order item was successfully updated.")
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "does not allow the seller to update the order item" do
        patch :update, params: { id: order_item.id, order_item: { quantity: 5 } }
        expect(response).to redirect_to(root_path)
        expect(order_item.reload.quantity).not_to eq(5)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "DELETE #destroy" do
    context "as a buyer" do
      before { sign_in buyer }

      it "allows the buyer to delete their order item" do
        expect {
          delete :destroy, params: { id: order_item.id }
        }.to change(OrderItem, :count).by(-1)

        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq("Order item was successfully deleted.")
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "does not allow the seller to delete an order item" do
        expect {
          delete :destroy, params: { id: order_item.id }
        }.not_to change(OrderItem, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
