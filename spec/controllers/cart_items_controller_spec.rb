require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let(:buyer) { create(:user, role: :buyer) }
  let(:other_user) { create(:user, role: :buyer) }
  let(:product) { create(:product, price: 20.0, stock: 5) }
  let(:cart) { buyer.create_cart }
  let(:other_user_cart) { other_user.create_cart }

  before do
    sign_in buyer
  end

  describe "POST #create adding a product to the buyer's cart" do
    context "when adding a new product to the signed-in user's cart" do
      it "creates a cart item and redirects to cart" do
        expect {
          post :create, params: { product_id: product.id, quantity: 2 }
        }.to change { cart.cart_items.count }.by(1).and change { other_user_cart.cart_items.count }.by(0)
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eq(I18n.t('cart_items.added_to_cart'))
        expect(cart.cart_items.last.product).to eq(product)
      end
    end

    context "when the product is already in the cart" do
      before { cart.cart_items.create(product: product, quantity: 3) }

      it "increments the cart item quantity and redirects to cart" do
        post :create, params: { product_id: product.id, quantity: 1 }
        cart_item = cart.cart_items.find_by(product_id: product.id)
        expect(cart_item.quantity).to eq(4)
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to eq(I18n.t('cart_items.quantity_updated'))
        expect(other_user_cart.cart_items.find_by(product_id: product.id)).to be_nil
      end
    end

    context "when quantity exceeds stock" do
      it "does not create a cart item and shows alert" do
        expect {
          post :create, params: { product_id: product.id, quantity: 10 }
        }.not_to change(CartItem, :count)
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eq(I18n.t('cart_items.exceed_stock'))
      end
    end
  end

  describe "PATCH #update to modify quantity in the cart" do
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 2) }
    let!(:other_user_cart_item) { other_user_cart.cart_items.create(product: product, quantity: 1) }

    context "when updating quantity within stock" do
      it "updates the quantity and redirects to cart" do
        patch :update, params: { id: cart_item.id, quantity: 4 }
        expect(response).to redirect_to(cart_path)
        expect(cart_item.reload.quantity).to eq(4)
        expect(flash[:notice]).to eq(I18n.t('cart_items.updated'))
      end
    end

    context "when updating quantity to exceed stock" do
      it "does not update and shows alert" do
        patch :update, params: { id: cart_item.id, quantity: 10 }
        expect(response).to redirect_to(cart_path)
        expect(cart_item.reload.quantity).to eq(2)
        expect(flash[:alert]).to eq(I18n.t('cart_items.exceed_stock'))
      end
    end
  end

  describe "DELETE #destroy removes items from cart" do
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 1) }
    let!(:other_user_cart_item) { other_user_cart.cart_items.create(product: product, quantity: 1) }

    it "removes the item and redirects to cart" do
      expect {
        delete :destroy, params: { id: cart_item.id }
      }.to change { cart.cart_items.count }.by(-1).and change { other_user_cart.cart_items.count }.by(0)

      expect(response).to redirect_to(cart_path)
      expect(flash[:notice]).to eq(I18n.t('cart_items.removed'))
      expect(other_user_cart.cart_items.find_by(id: other_user_cart_item.id)).to be_present
    end
  end
end
