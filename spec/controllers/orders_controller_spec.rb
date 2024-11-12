# require 'rails_helper'

# RSpec.describe OrdersController, type: :controller do
#   include Devise::Test::ControllerHelpers
  
#   before(:each) do
#     @request.env["devise.mapping"] = Devise.mappings[:user]
#   end

#   let(:buyer) { create(:user, role: 'buyer') }
#   let(:seller) { create(:user, role: 'seller') }
#   let(:other_seller) { create(:user, role: 'seller') }
#   let(:rider) { create(:user, role: 'rider') }
#   let(:admin) { create(:user, role: 'admin') }
#   let(:product1) { create(:product, user: seller, stock: 10, price: 100) }
#   let(:product2) { create(:product, user: other_seller, stock: 5, price: 50) }
#   let(:order) { create(:order, user: buyer, total_price: 250, status: 'pending') }
#   let!(:order_item1) { create(:order_item, order: order, product: product1, quantity: 2, price: product1.price) }
#   let!(:order_item2) { create(:order_item, order: order, product: product2, quantity: 1, price: product2.price) }

#   describe "GET #index" do
#     context "as a buyer" do
#       before { sign_in buyer }

#       it "shows only the buyer's orders" do
#         get :index
#         expect(assigns(:orders)).to include(order)
#         expect(assigns(:orders).size).to eq(1)
#       end
#     end

#     context "as a seller" do
#       before { sign_in seller }

#       it "shows orders containing the seller's products" do
#         get :index
#         expect(assigns(:orders)).to include(order)
#       end

#       it "does not show unrelated orders" do
#         unrelated_order = create(:order, user: buyer)
#         create(:order_item, order: unrelated_order, product: create(:product))
#         get :index
#         expect(assigns(:orders)).not_to include(unrelated_order)
#       end
#     end

#     context "as a rider" do
#       before { sign_in rider }

#       it "shows orders assigned to the rider" do
#         order_item1.update(rider: rider)
#         get :index
#         expect(assigns(:orders)).to include(order)
#       end
#     end

#     context "as an admin" do
#       before { sign_in admin }

#       it "shows all orders with items sent to delivery company" do
#         order_item1.update(status: 'sent_to_delivery_company')
#         get :index
#         expect(assigns(:orders)).to include(order)
#       end
#     end
#   end

#   describe "GET #show" do
#     context "as the buyer who owns the order" do
#       before { sign_in buyer }

#       it "displays the buyer's order details" do
#         get :show, params: { id: order.id }
#         expect(response).to render_template(:show)
#         expect(assigns(:order)).to eq(order)
#         expect(assigns(:order_items)).to include(order_item1, order_item2)
#       end
#     end

#     context "as the seller with related products" do
#       before { sign_in seller }

#       it "shows only the seller's product in the order items" do
#         get :show, params: { id: order.id }
#         expect(assigns(:order_items)).to include(order_item1)
#         expect(assigns(:order_items)).not_to include(order_item2)
#       end
#     end

#     context "as a rider assigned to the order items" do
#       before do
#         order_item1.update(rider: rider)
#         sign_in rider
#       end

#       it "shows only the items assigned to the rider" do
#         get :show, params: { id: order.id }
#         expect(assigns(:order_items)).to include(order_item1)
#         expect(assigns(:order_items)).not_to include(order_item2)
#       end
#     end
#   end

#   describe "POST #create" do
#     before do
#       sign_in buyer
#       buyer.create_cart
#       buyer.cart.cart_items.create(product: product1, quantity: 1)
#     end

#     context "when stock is sufficient" do
#       it "creates an order and clears the cart" do
#         expect { post :create }.to change(Order, :count).by(1)
#         expect(buyer.cart.cart_items.count).to eq(0)
#         expect(response).to redirect_to(order_path(assigns(:order)))
#         expect(flash[:notice]).to eq(I18n.t('orders.created'))
#       end
#     end

#     context "when stock is insufficient" do
#       it "does not create an order and redirects with an alert" do
#         product1.update(stock: 0)
#         post :create
#         expect(Order.count).to eq(0)
#         expect(response).to redirect_to(cart_path)
#         expect(flash[:alert]).to eq(I18n.t('orders.insufficient_stock', title: product1.title))
#       end
#     end
#   end


#   describe "PATCH #update_status" do
#     context "as an admin assigning a rider" do
#       before { sign_in admin }

#       it "assigns a rider and updates status to 'rider_assigned'" do
#         patch :update_status, params: { id: order.id, order_item_id: order_item1.id, rider_id: rider.id, status: 'rider_assigned' }
#         expect(order_item1.reload.status).to eq('rider_assigned')
#         expect(order_item1.rider_id).to eq(rider.id)
#         expect(response).to redirect_to(order_path(order))
#         expect(flash[:notice]).to eq(I18n.t('orders.rider_assigned'))
#       end
#     end

#     context "as a seller updating their own product's order item" do
#       before { sign_in seller }

#       it "updates status to 'sent_to_delivery_company'" do
#         patch :update_status, params: { id: order.id, order_item_id: order_item1.id, status: 'sent_to_delivery_company' }
#         expect(order_item1.reload.status).to eq('sent_to_delivery_company')
#         expect(response).to redirect_to(order_path(order))
#         expect(flash[:notice]).to eq(I18n.t('orders.status_updated'))
#       end

#       it "does not allow invalid status updates" do
#         patch :update_status, params: { id: order.id, order_item_id: order_item1.id, status: 'completed' }
#         expect(order_item1.reload.status).not_to eq('completed')
#         expect(response).to redirect_to(order_path(order))
#         expect(flash[:alert]).to eq(I18n.t('orders.seller_status_limit'))
#       end
#     end

#     context "as a buyer confirming receipt" do
#       before do
#         sign_in buyer
#         order_item1.update(status: 'delivered')
#       end

#       it "updates status to 'received'" do
#         patch :update_status, params: { id: order.id, order_item_id: order_item1.id, status: 'received' }
#         expect(order_item1.reload.status).to eq('received')
#         expect(response).to redirect_to(order_path(order))
#         expect(flash[:notice]).to eq(I18n.t('orders.received'))
#       end
#     end

#     context "unauthorized update attempts" do
#       before { sign_in buyer }

#       it "prevents unauthorized status updates" do
#         patch :update_status, params: { id: order.id, order_item_id: order_item1.id, status: 'sent_to_delivery_company' }
#         expect(response).to redirect_to(orders_path)
#         expect(flash[:alert]).to eq(I18n.t('orders.unauthorized_action'))
#       end
#     end
#   end
# end
# spec/controllers/order_items_controller_spec.rb

require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:other_seller) { create(:user, role: 'seller') }
  let(:rider) { create(:user, role: 'rider') }
  let(:admin) { create(:user, role: 'admin') }
  let(:product1) { create(:product, user: seller, stock: 10, price: 100) }
  let(:product2) { create(:product, user: other_seller, stock: 5, price: 50) }
  let(:order) { create(:order, user: buyer, total_price: 250, status: 'pending') }
  let!(:order_item1) { create(:order_item, order: order, product: product1, quantity: 2, price: product1.price) }
  let!(:order_item2) { create(:order_item, order: order, product: product2, quantity: 1, price: product2.price) }

  describe "GET #index" do
    context "as a buyer" do
      before { sign_in buyer }

      it "shows only the buyer's orders" do
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

      it "does not show unrelated orders" do
        unrelated_order = create(:order, user: buyer)
        create(:order_item, order: unrelated_order, product: create(:product))
        get :index
        expect(assigns(:orders)).not_to include(unrelated_order)
      end
    end

    context "as a rider" do
      before { sign_in rider }

      it "shows orders assigned to the rider" do
        order_item1.update(rider: rider)
        get :index
        expect(assigns(:orders)).to include(order)
      end
    end

    context "as an admin" do
      before { sign_in admin }

      it "shows all orders with items sent to delivery company" do
        order_item1.update(status: 'sent_to_delivery_company')
        get :index
        expect(assigns(:orders)).to include(order)
      end
    end
  end

  describe "GET #show" do
    context "as the buyer who owns the order" do
      before { sign_in buyer }

      it "displays the buyer's order details" do
        get :show, params: { id: order.id }
        expect(response).to render_template(:show)
        expect(assigns(:order)).to eq(order)
        expect(assigns(:order_items)).to include(order_item1, order_item2)
      end
    end

    context "as the seller with related products" do
      before { sign_in seller }

      it "shows only the seller's product in the order items" do
        get :show, params: { id: order.id }
        expect(assigns(:order_items)).to include(order_item1)
        expect(assigns(:order_items)).not_to include(order_item2)
      end
    end

    context "as a rider assigned to the order items" do
      before do
        order_item1.update(rider: rider)
        sign_in rider
      end

      it "shows only the items assigned to the rider" do
        get :show, params: { id: order.id }
        expect(assigns(:order_items)).to include(order_item1)
        expect(assigns(:order_items)).not_to include(order_item2)
      end
    end
  end

  describe "POST #create" do
    before do
      sign_in buyer
      buyer.create_cart
      buyer.cart.cart_items.create(product: product1, quantity: 1)
    end

    context "when stock is sufficient" do
      it "creates an order and clears the cart" do
        expect { post :create }.to change(Order, :count).by(1)
        expect(buyer.cart.cart_items.count).to eq(0)
        expect(response).to redirect_to(order_path(assigns(:order)))
        expect(flash[:notice]).to eq(I18n.t('orders.created'))
      end
    end

    context "when stock is insufficient" do
      it "does not create an order and redirects with an alert" do
        product1.update(stock: 0)
        post :create
        expect(Order.count).to eq(0)
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eq(I18n.t('orders.insufficient_stock', title: product1.title))
      end
    end
  end
end
