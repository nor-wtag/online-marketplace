require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:other_seller) { create(:user, role: 'seller') }
  let(:product1) { create(:product, user: seller, stock: 10) }
  let(:product2) { create(:product, user: other_seller, stock: 5) }
  let(:order) { create(:order, user: buyer, total_price: 100, status: 'pending') }
  let!(:order_item1) { create(:order_item, order: order, product: product1, quantity: 2, price: product1.price) }
  let!(:order_item2) { create(:order_item, order: order, product: product2, quantity: 1, price: product2.price) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #index to view orders" do
    context "as a buyer" do
      before { sign_in buyer }

      it "shows only the buyer's orders" do
        get :index
        expect(assigns(:orders)).to include(order)
      end
    end

    context "as a seller" do
      before { sign_in seller }

      it "shows orders that contain the seller's products" do
        get :index
        expect(assigns(:orders)).to include(order)
      end

      it "does not show orders with other sellers' products" do
        other_order = create(:order, user: buyer, total_price: 50, status: 'pending')
        create(:order_item, order: other_order, product: product2)
        get :index
        expect(assigns(:orders)).not_to include(other_order)
      end
    end
  end

  describe "GET #show to view order details" do
    context "as the buyer who owns the order" do
      before { sign_in buyer }

      it "displays the buyer's order details" do
        get :show, params: { id: order.id }
        expect(response).to render_template(:show)
        expect(assigns(:order)).to eq(order)
      end
    end

    context "as the seller who owns one of the order items" do
      before { sign_in seller }

      it "shows only the seller's own product in the order items" do
        get :show, params: { id: order.id }
        expect(assigns(:order_items)).to include(order_item1)
        expect(assigns(:order_items)).not_to include(order_item2)
      end
    end
  end

  describe "POST #create to create orders" do
    context "as a buyer" do
      before do
        sign_in buyer
        buyer.create_cart
        buyer.cart.cart_items.create(product: product1, quantity: 2)
        buyer.cart.cart_items.create(product: product2, quantity: 1)
      end

      it "successfully creates an order if stock is sufficient" do
        expect {
          post :create
        }.to change(Order, :count).by(1)
        expect(response).to redirect_to(assigns(:order))
        expect(flash[:notice]).to eq("Order was successfully created.")
      end

      it "reduces the stock of each product in the order" do
        post :create
        expect(product1.reload.stock).to eq(8)
        expect(product2.reload.stock).to eq(4)
      end

      it "clears the buyer's cart after the order is placed" do
        post :create
        expect(buyer.cart.cart_items.count).to eq(0)
      end

      it "does not create an order if stock is insufficient" do
        product1.update(stock: 1)
        post :create
        expect(Order.count).to eq(0)
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eq("Insufficient stock for #{product1.title}. Order could not be created.")
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

  describe "PATCH #cancel to cancel an order" do
    context "as the buyer who owns the order" do
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

  describe "PATCH #update_status for updating order item status" do
    context "as the seller who owns the product" do
      before { sign_in seller }

      it "updates the order item status if the seller owns the product" do
        patch :update_status, params: { order_id: order.id, id: order_item1.id, order_item: { status: 'sent_to_delivery_company' } }
        expect(order_item1.reload.status).to eq('sent_to_delivery_company')
        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq("Order item status updated successfully.")
      end
    end

    context "as a different seller" do
      before { sign_in other_seller }

      it "does not allow updating another seller's order item status" do
        patch :update_status, params: { order_id: order.id, id: order_item1.id, order_item: { status: 'sent_to_delivery_company' } }
        expect(order_item1.reload.status).to eq('pending')
        expect(response).to redirect_to(orders_path)
        expect(flash[:alert]).to eq("You are not authorized to update this order item.")
      end
    end

    context "as a buyer" do
      before { sign_in buyer }

      it "does not allow a buyer to update order item status" do
        patch :update_status, params: { order_id: order.id, id: order_item1.id, order_item: { status: 'delivered' } }
        expect(response).to redirect_to(orders_path)
        expect(flash[:alert]).to eq("You are not authorized to update order items.")
      end
    end
  end
end
