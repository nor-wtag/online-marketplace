# spec/controllers/orders_controller_spec.rb
require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:product) { create(:product, user: seller) }
  let(:order) { create(:order, user: buyer, total_price: 100, status: "pending") }
  let!(:order_item) { create(:order_item, order: order, product: product, quantity: 1, price: 100) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #index" do
    context "as a buyer" do
      before { sign_in buyer }

      it "shows the buyer's orders" do
        get :index
        expect(assigns(:orders)).to include(order)
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "shows orders containing the seller's products" do
        get :index
        expect(assigns(:orders)).to include(order)
      end
    end
  end

  describe "GET #show" do
    context "as a buyer" do
      before { sign_in buyer }

      it "displays the buyer's order details" do
        get :show, params: { id: order.id }
        expect(response).to render_template(:show)
        expect(assigns(:order)).to eq(order)
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "allows the seller to view the order details if it contains their products" do
        get :show, params: { id: order.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe "POST #create" do
    context "as a buyer" do
      before do
        sign_in buyer
        buyer.create_cart! # Ensure the buyer has a cart before creating an order
        buyer.cart.cart_items.create!(product: product, quantity: 1) # Add a product to the cart
      end
  
      it "creates a new order for the buyer" do
        post :create
        expect(response).to redirect_to(assigns(:order))
        expect(flash[:notice]).to eq("Order was successfully created.")
      end
    end
  
    context "as a seller" do
      before { sign_in seller }
  
      it "does not allow a seller to create an order" do
        post :create
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to create an order.")
      end
    end
  end

  describe "PATCH #cancel" do
    context "as a buyer" do
      before { sign_in buyer }

      it "allows the buyer to cancel their order" do
        patch :cancel, params: { id: order.id }
        expect(order.reload.status).to eq("canceled")
        expect(response).to redirect_to(orders_path)
        expect(flash[:notice]).to eq("Order was successfully canceled.")
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "does not allow the seller to cancel an order" do
        patch :cancel, params: { id: order.id }
        expect(response).to redirect_to(orders_path)
        expect(flash[:alert]).to eq("You are not authorized to cancel this order.")
      end
    end
  end
end
