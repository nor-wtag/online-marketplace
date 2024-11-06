require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  let(:user) { create(:user, role: :buyer) }
  let(:product1) { create(:product, price: 10.0) }
  let(:product2) { create(:product, price: 15.0) }
  let(:cart) { create(:cart, user: user) }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET /cart page after clicking it" do
    it "returns http success for cart show when redirected to it" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show all the products added to cart" do
    render_views
    context "when cart has items" do
      before do
        cart.cart_items.create(product: product1, quantity: 2)
        cart.cart_items.create(product: product2, quantity: 3)
      end

      it "displays all items in the cart" do
        get :show
        expect(response).to render_template(:show)
        expect(assigns(:cart_items).size).to eq(2)
      end

      it "calculates the correct total price" do
        get :show
        expect(assigns(:cart).total_price).to eq(65.0)
      end
    end

    context "when cart is empty" do
      it "shows empty cart message" do
        get :show
        expect(assigns(:cart_items)).to be_empty
        expect(response.body).to include("Your cart is empty")
      end
    end
  end
end
