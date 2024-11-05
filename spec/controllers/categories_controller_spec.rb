require 'rails_helper'
RSpec.describe CategoriesController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:category) { create(:category) }
  let(:product1) { create(:product) }
  let(:product2) { create(:product) }

  describe "GET #index to view all categories" do
    context "as an admin" do
      it "allows access and lists all categories" do
        sign_in admin
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:categories)).to include(category)
      end
    end

    context "as a guest" do
      it "redirects to the sign-in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #show to view category details" do
    context "with a valid category ID" do
      it "allows access to view the category" do
        sign_in admin
        get :show, params: { id: category.id }
        expect(response).to render_template(:show)
        expect(assigns(:category)).to eq(category)
      end
    end

    context "with an invalid category ID" do
      it "redirects to index with an alert" do
        sign_in admin
        get :show, params: { id: 0 }
        expect(response).to redirect_to(categories_path)
        expect(flash[:alert]).to eq('Category not found')
      end
    end
  end

  describe "GET #new for creating a new category" do
    context "as an admin" do
      it "allows access to create a new category" do
        sign_in admin
        get :new
        expect(response).to render_template(:new)
      end
    end

    context "as a seller or buyer" do
      it "denies access to new category for a seller" do
        sign_in seller
        expect { get :new }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "POST #create a category" do
    let(:valid_attributes) { attributes_for(:category) }

    context "as an admin" do
      before { sign_in admin }

      it "creates a new category with valid attributes" do
        expect {
          post :create, params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
        expect(response).to redirect_to(categories_path)
      end

      it "assigns multiple products to the category" do
        post :create, params: { category: valid_attributes.merge(product_ids: [product1.id, product2.id]) }
        category = Category.last
        expect(category.products).to include(product1, product2)
      end
    end

    context "as a seller or buyer" do
      it "does not allow category creation for a seller" do
        sign_in seller
        expect {
          post :create, params: { category: valid_attributes }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "GET #edit to edit a category" do
    context "as an admin" do
      it "allows editing of the category" do
        sign_in admin
        get :edit, params: { id: category.id }
        expect(response).to render_template(:edit)
      end
    end

    context "as a seller or buyer" do
      it "denies editing for a seller" do
        sign_in seller
        expect { get :edit, params: { id: category.id } }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "PATCH #update to update a category" do
    context "as an admin" do
      it "updates the category with valid attributes" do
        sign_in admin
        patch :update, params: { id: category.id, category: { name: "Updated Name" } }
        category.reload
        expect(category.name).to eq("Updated Name")
        expect(response).to redirect_to(categories_path)
      end
    end

    context "as a seller or buyer" do
      it "denies updating for a seller" do
        sign_in seller
        expect {
          patch :update, params: { id: category.id, category: { name: "Updated Name" } }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "DELETE #destroy to delete a category" do
    context "as an admin" do
      it "deletes the category" do
        sign_in admin
        delete :destroy, params: { id: category.id }
        expect(response).to redirect_to(categories_path)
        expect(Category.exists?(category.id)).to be_falsey
      end
    end

    context "as a seller or buyer" do
      it "denies deletion for a seller" do
        sign_in seller
        expect { delete :destroy, params: { id: category.id } }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
