require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do
  let(:buyer) { create(:user, role: :buyer) }
  let(:other_user) { create(:user, role: :buyer) }
  let(:product) { create(:product, price: 20.0,  stock: 5) }
  let(:cart) { buyer.create_cart }
  let(:other_user_cart) { other_user.create_cart }

  before do
    sign_in buyer
  end

  describe "POST #create adding a product to the buyer's cart" do
    context "when adding a new product to the signed-in user's cart" do
      it "creates a cart item for the buyer's cart only and redirects to cart" do
        expect {
          post :create, params: { product_id: product.id, quantity: 2 }
        }.to change { cart.cart_items.count }.by(1).and change { other_user_cart.cart_items.count }.by(0)
        expect(response).to redirect_to(cart_path)
        expect(cart.cart_items.last.product).to eq(product)
      end
    end

    context "when the product is already in the cart" do
      before { cart.cart_items.create(product: product, quantity: 3) }

      it "increments the cart item quantity in the buyer's cart only" do
        post :create, params: { product_id: product.id, quantity: 1 }
        cart_item = cart.cart_items.find_by(product_id: product.id)
        expect(cart_item.quantity).to eq(4)
        expect(response).to redirect_to(cart_path)
        expect(other_user_cart.cart_items.find_by(product_id: product.id)).to be_nil
      end
    end

    context "when quantity is within stock and is a valid quantity " do
      it "creates a cart item for the buyer's cart and redirects to cart" do
        expect {
          post :create, params: { product_id: product.id, quantity: 3 }
        }.to change { cart.cart_items.count }.by(1)
        expect(response).to redirect_to(cart_path)
        expect(cart.cart_items.last.quantity).to eq(3)
      end
    end

    context "when quantity exceeds stock" do
      it "does not create a cart item and redirects with an alert" do
        expect {
          post :create, params: { product_id: product.id, quantity: 10 }
        }.not_to change(CartItem, :count)
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eq("Cannot add more than available stock.")
      end
    end
  end

  describe "PATCH #update updates only the signed-in user's cart items" do
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 2) }
    let!(:other_user_cart_item) { other_user_cart.cart_items.create(product: product, quantity: 1) }

    context "when updating quantity within stock" do
      it "updates the cart item quantity and redirects to cart" do
        patch :update, params: { id: cart_item.id, quantity: 4 }
        expect(response).to redirect_to(cart_path)
        expect(cart_item.reload.quantity).to eq(4)
      end
    end

    context "when updating quantity to exceed stock" do
      it "does not update and shows an alert" do
        patch :update, params: { id: cart_item.id, quantity: 10 }
        expect(response).to redirect_to(cart_path)
        expect(cart_item.reload.quantity).to eq(2)
        expect(flash[:alert]).to eq("Cannot exceed available stock.")
      end
    end

    context "with quantity 0" do
      it "removes the cart item from the buyer's cart only" do
        expect {
          patch :update, params: { id: cart_item.id, quantity: 0 }
        }.to change { cart.cart_items.count }.by(-1).and change { other_user_cart.cart_items.count }.by(0)

        expect(response).to redirect_to(cart_path)
      end
    end
  end

  describe "DELETE #destroy removes items only from the signed-in user's cart" do
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 1) }
    let!(:other_user_cart_item) { other_user_cart.cart_items.create(product: product, quantity: 1) }

    it "removes the item from the buyer's cart only and redirects to cart" do
      expect {
        delete :destroy, params: { id: cart_item.id }
      }.to change { cart.cart_items.count }.by(-1).and change { other_user_cart.cart_items.count }.by(0)

      expect(response).to redirect_to(cart_path)
      expect(other_user_cart.cart_items.find_by(id: other_user_cart_item.id)).to be_present
    end
  end
end
