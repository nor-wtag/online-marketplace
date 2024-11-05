require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:product) { create(:product, user: seller) }
  let(:category1) { create(:category) }
  let(:category2) { create(:category) }

  describe "GET #index to go to the products page" do
    context "with a valid product ID" do
      it "allows access to view the product" do
        sign_in admin
        get :show, params: { id: product.id }
        expect(response).to render_template(:show)
        expect(assigns(:product)).to eq(product)
      end
    end

    context "with an invalid product ID" do
      it "redirects to index with an alert" do
        sign_in admin
        get :show, params: { id: 0 }
        expect(response).to redirect_to(products_path)
        expect(flash[:alert]).to eq('Product not found')
      end
    end

    context "as a guest" do
      it "redirects to the sign-in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #show to view details of the product" do
    context "as an admin" do
      it "allows access to view the product" do
        sign_in admin
        get :show, params: { id: product.id }
        expect(response).to render_template(:show)
        expect(assigns(:product)).to eq(product)
      end
    end

    context "as a buyer" do
      it "allows access to view the product" do
        sign_in buyer
        get :show, params: { id: product.id }
        expect(response).to render_template(:show)
        expect(assigns(:product)).to eq(product)
      end
    end
  end

  describe "GET #new for creating new products" do
    context "as a seller" do
      it "allows access to create a new product" do
        sign_in seller
        get :new
        expect(response).to render_template(:new)
      end
    end

    context "as a buyer" do
      it "denies access to new product" do
        sign_in buyer
        expect {
          get :new
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "POST #create products" do
    let(:valid_attributes) { attributes_for(:product) }

    context "as a seller" do
      before { sign_in seller }

      it "creates a new product with valid attributes" do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
        expect(response).to redirect_to(products_path)
      end

      it "assigns multiple categories to the products" do
        post :create, params: { product: valid_attributes.merge(category_ids: [ category1.id, category2.id ]) }
        product = Product.last
        expect(product.categories).to include(category1, category2)
        expect(response).to redirect_to(products_path)
      end
    end

    context "as a buyer" do
      it "does not allow product creation" do
        sign_in buyer
        expect {
          post :create, params: { product: valid_attributes }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "GET #edit option for editing products" do
    context "as the seller who is the product owner" do
      it "allows editing" do
        sign_in seller
        get :edit, params: { id: product.id }
        expect(response).to render_template(:edit)
      end
    end

    context "as a different seller" do
      it "denies editing another seller's product" do
        other_seller = create(:user, role: 'seller')
        sign_in other_seller
        expect {
          get :edit, params: { id: product.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "PATCH #update Product with values" do
    context "as the product owner" do
      it "updates product with valid attributes" do
        sign_in seller
        patch :update, params: { id: product.id, product: { title: "Updated Title" } }
        product.reload
        expect(product.title).to eq("Updated Title")
        expect(response).to redirect_to(products_path)
      end
    end

    context "as a different seller" do
      it "denies updating another seller's product" do
        other_seller = create(:user, role: 'seller')
        sign_in other_seller
        expect {
          patch :update, params: { id: product.id, product: { title: "Updated Title" } }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "DELETE #destroy the product" do
    context "as an admin" do
      it "deletes any product" do
        sign_in admin
        delete :destroy, params: { id: product.id }
        expect(response).to redirect_to(products_path)
        expect(Product.exists?(product.id)).to be_falsey
      end
    end

    context "as the product owner" do
      it "deletes own product" do
        sign_in seller
        delete :destroy, params: { id: product.id }
        expect(response).to redirect_to(products_path)
      end
    end

    context "as a buyer" do
      it "does not allow deletion" do
        sign_in buyer
        expect {
          delete :destroy, params: { id: product.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
