require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do
  let(:user) { create(:user, role: :buyer) }
  let(:product) { create(:product, price: 20.0) }
  let(:cart) { user.create_cart }

  before do
    sign_in user
  end

  describe "POST #create adding a product to cart so it gets added as a cart item" do
    context "when adding a new product to cart" do
      it "creates a cart item and redirects to cart" do
        expect {
          post :create, params: { product_id: product.id, quantity: 2 }
        }.to change(CartItem, :count).by(1)
        expect(response).to redirect_to(cart_path)
      end
    end
  
    context "when product is already in cart" do
      before { cart.cart_items.create(product: product, quantity: 3) }
      it "increments the cart item quantity" do
        post :create, params: { product_id: product.id, quantity: 1 }
        cart_item = cart.cart_items.find_by(product_id: product.id)
        expect(cart_item.quantity).to eq(4)
        expect(response).to redirect_to(cart_path)
      end
    end
  end

  describe "PATCH #update the values of the cart items" do
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 1) }

    context "with valid quantity" do
      it "updates the quantity of the cart item" do
        patch :update, params: { id: cart_item.id, quantity: 5 }
        cart_item.reload
        expect(cart_item.quantity).to eq(5)
        expect(response).to redirect_to(cart_path)
      end
    end

    context "with quantity 0" do
      it "removes the cart item" do
        expect {
          patch :update, params: { id: cart_item.id, quantity: 0 }
        }.to change(CartItem, :count).by(-1)
        expect(response).to redirect_to(cart_path)
      end
    end
  end

  describe "DELETE #destroy removing the item from the cart" do
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 1) }

    it "removes the item from the cart and redirects to cart" do
      expect {
        delete :destroy, params: { id: cart_item.id }
      }.to change(CartItem, :count).by(-1)
      expect(response).to redirect_to(cart_path)
    end
  end
end
