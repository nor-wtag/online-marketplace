require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:user) { create(:user) }
  let(:product) { create(:product, user: user) }
  let(:category1) { create(:category) }
  let(:category2) { create(:category) }

  before do
    sign_in user
  end

  describe "Getting index page for product to view all the products" do
    it "assigns all products and renders the index template" do
      get :index
      expect(assigns(:products)).to eq([product])
      expect(response).to render_template(:index)
    end
  end

  describe "Getting the new page to create a product" do
    it "assigns a new product and renders the new template" do
      get :new
      expect(assigns(:product)).to be_a_new(Product)
      expect(response).to render_template(:new)
    end
  end

  describe "Creating a new product" do
    context "with valid attributes" do
      it "creates a new product and redirects to index" do
        expect {
          post :create, params: { product: attributes_for(:product) }
        }.to change(Product, :count).by(1)
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('Product was successfully created.')
      end
    end

    context "when creating a product with multiple categories" do
      it "assigns multiple categories to the product" do
        post :create, params: { product: attributes_for(:product).merge(category_ids: [category1.id, category2.id]) }
        product = Product.last
        expect(product.categories).to include(category1, category2)
        expect(response).to redirect_to(products_path)
      end
    end

    context "with invalid attributes" do
      it "does not save the product and re-renders the new template with errors" do
        post :create, params: { product: attributes_for(:product, title: "") }
        expect(assigns(:product).errors[:title]).not_to be_empty
        expect(response).to render_template(:new)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "Showing all the details of a product" do
    context "with a valid product ID" do
      it "assigns the requested product and renders the show template" do
        get :show, params: { id: product.id }
        expect(assigns(:product)).to eq(product)
        expect(response).to render_template(:show)
      end
    end

    context "with an invalid product ID" do
      it "redirects to index with an alert" do
        get :show, params: { id: 0 }
        expect(response).to redirect_to(products_path)
        expect(flash[:alert]).to eq('Product not found')
      end
    end
  end

  describe "Rendering edit page to update product" do
    it "assigns the requested product and renders the edit template" do
      get :edit, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
      expect(response).to render_template(:edit)
    end
  end

  describe "Updating product" do
    context "with valid attributes" do
      it "updates the product and redirects to index with a notice" do
        patch :update, params: { id: product.id, product: { title: "Updated Title" } }
        product.reload
        expect(product.title).to eq("Updated Title")
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('Product was successfully updated.')
      end
    end

    context "when updating a product with multiple categories" do
      it "updates the product to have multiple categories" do
        patch :update, params: { id: product.id, product: { category_ids: [category1.id, category2.id] } }
        product.reload
        expect(product.categories).to include(category1, category2)
        expect(response).to redirect_to(products_path)
      end
    end

    context "with invalid attributes" do
      it "does not update the product and re-renders the edit template with errors" do
        patch :update, params: { id: product.id, product: { title: "" } }
        expect(assigns(:product).errors[:title]).not_to be_empty
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "deleting a product" do
    context "with a valid product ID" do
      it "deletes the product and redirects to index with a notice" do
        product
        expect {
          delete :destroy, params: { id: product.id }
        }.to change(Product, :count).by(-1)
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('Product was successfully deleted.')
      end
    end

    context "with an invalid product ID" do
      it "redirects to index with an alert" do
        delete :destroy, params: { id: 0 }
        expect(response).to redirect_to(products_path)
        expect(flash[:alert]).to eq('Product not found')
      end
    end
  end
end
