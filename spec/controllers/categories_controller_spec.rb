require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product1) { create(:product) }
  let(:product2) { create(:product) }

  before do
    sign_in user
  end

  describe "Getting index page to view all the categories" do
    it "assigns all categories and renders the index template" do
      get :index
      expect(assigns(:categories)).to eq([category])
      expect(response).to render_template(:index)
    end
  end

  describe "Getting the new page to create a new category" do
    it "assigns a new category and renders the new template" do
      get :new
      expect(assigns(:category)).to be_a_new(Category)
      expect(response).to render_template(:new)
    end
  end

  describe "Creating a category" do
    context "with valid attributes" do
      it "creates a new category and redirects to index" do
        expect {
          post :create, params: { category: attributes_for(:category) }
        }.to change(Category, :count).by(1)
        expect(response).to redirect_to(categories_path)
        expect(flash[:notice]).to eq('Category was successfully created.')
      end
    end

    context "when creating a category with multiple products" do
      it "assigns multiple products to the category" do
        post :create, params: { category: attributes_for(:category).merge(product_ids: [product1.id, product2.id]) }
        category = Category.last
        expect(category.products).to include(product1, product2)
        expect(response).to redirect_to(categories_path)
      end
    end

    context "with invalid attributes" do
      it "does not save the category and re-renders the new template with errors" do
        post :create, params: { category: attributes_for(:category, name: "") }
        expect(assigns(:category).errors[:name]).not_to be_empty
        expect(response).to render_template(:new)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "Showing details of a category" do
    context "with a valid category ID" do
      it "assigns the requested category and renders the show template" do
        get :show, params: { id: category.id }
        expect(assigns(:category)).to eq(category)
        expect(response).to render_template(:show)
      end
    end

    context "with an invalid category ID" do
      it "redirects to index with an alert" do
        get :show, params: { id: 0 }
        expect(response).to redirect_to(categories_path)
        expect(flash[:alert]).to eq('Category not found')
      end
    end
  end

  describe "Editing a category" do
    it "assigns the requested category and renders the edit template" do
      get :edit, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
      expect(response).to render_template(:edit)
    end
  end

  describe "Updating a category" do
    context "with valid attributes" do
      it "updates the category and redirects to index with a notice" do
        patch :update, params: { id: category.id, category: { name: "Updated Name" } }
        category.reload
        expect(category.name).to eq("Updated Name")
        expect(response).to redirect_to(categories_path)
        expect(flash[:notice]).to eq('Category was successfully updated.')
      end
    end

    context "when updating a category with multiple products" do
      it "updates the category to have multiple products" do
        patch :update, params: { id: category.id, category: { product_ids: [product1.id, product2.id] } }
        category.reload
        expect(category.products).to include(product1, product2)
        expect(response).to redirect_to(categories_path)
      end
    end

    context "with invalid attributes" do
      it "does not update the category and re-renders the edit template with errors" do
        patch :update, params: { id: category.id, category: { name: "" } }
        expect(assigns(:category).errors[:name]).not_to be_empty
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "Deleting a category" do
    context "with a valid category ID" do
      it "deletes the category and redirects to index with a notice" do
        category # Ensure the category is created
        expect {
          delete :destroy, params: { id: category.id }
        }.to change(Category, :count).by(-1)
        expect(response).to redirect_to(categories_path)
        expect(flash[:notice]).to eq('Category was successfully deleted.')
      end
    end

    context "with an invalid category ID" do
      it "redirects to index with an alert" do
        delete :destroy, params: { id: 0 }
        expect(response).to redirect_to(categories_path)
        expect(flash[:alert]).to eq('Category not found')
      end
    end
  end

end
