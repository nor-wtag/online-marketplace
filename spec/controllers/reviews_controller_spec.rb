require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  let(:admin) { create(:user, role: 'admin') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:product) { create(:product, user: seller) }
  let(:order) { create(:order, user: buyer, status: 'completed') }
  let!(:order_item) { create(:order_item, order: order, product: product) }
  let!(:review) { create(:review, user: buyer, product: product) }

  before do
    allow_any_instance_of(ReviewsController).to receive(:purchased_product?).and_return(true)
  end

  describe "GET #index" do
    context "as an admin" do
      it "allows access to all reviews" do
        sign_in admin
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:reviews)).to include(review)
      end
    end
  end

  describe "GET #show" do
    context "as a buyer" do
      it "displays all reviews for the product" do
        sign_in buyer
        get :show, params: { id: review.id }
        expect(response).to render_template(:show)
        expect(assigns(:reviews)).to include(review)
      end
    end

    context "as a seller" do
      it "allows access to review details for a product they own" do
        sign_in seller
        get :show, params: { id: review.id }
        expect(response).to render_template(:show)
        expect(assigns(:reviews)).to include(review)
      end
    end
  end

  describe "GET #new" do
    context "as a buyer who purchased the product" do
      it "renders the new review form" do
        sign_in buyer
        get :new, params: { product_id: product.id }
        expect(response).to render_template(:new)
        expect(assigns(:review)).to be_a_new(Review)
      end
    end

    context "as a buyer who hasn't purchased the product" do
      before { allow_any_instance_of(ReviewsController).to receive(:purchased_product?).and_return(false) }

      it "redirects with an alert" do
        sign_in buyer
        get :new, params: { product_id: product.id }
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq('You can only review products you have purchased.')
      end
    end

    context "as a seller" do
      it "does not render the new review form and raises CanCan::AccessDenied" do
        sign_in seller
        expect {
          get :new, params: { product_id: product.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "POST #create" do
    context "as a buyer who purchased the product" do
      it "creates a new review and redirects to the product page" do
        sign_in buyer
        expect {
          post :create, params: { product_id: product.id, review: { rating: 4, comment: "Great product!" } }
        }.to change(Review, :count).by(1)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq('Review was successfully created.')
      end
    end

    context "as a buyer who hasn't purchased the product" do
      before { allow_any_instance_of(ReviewsController).to receive(:purchased_product?).and_return(false) }

      it "does not create a review and redirects with an alert" do
        sign_in buyer
        expect {
          post :create, params: { product_id: product.id, review: { rating: 4, comment: "Great product!" } }
        }.not_to change(Review, :count)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq('You can only review products you have purchased.')
      end
    end

    context "when the review is invalid" do
      it "re-renders the new form with errors" do
        sign_in buyer
        post :create, params: { product_id: product.id, review: { rating: nil, comment: "" } }
        expect(response).to render_template(:new)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET #edit" do
    it "renders the edit form for the review owner" do
      sign_in buyer
      get :edit, params: { id: review.id, product_id: product.id }
      expect(response).to render_template(:edit)
      expect(assigns(:review)).to eq(review)
    end
  end

  describe "PATCH #update" do
    context "when the review is valid and made by the buyer themself" do
      it "updates the review and redirects to the product page" do
        sign_in buyer
        patch :update, params: { id: review.id, product_id: product.id, review: { rating: 5, comment: "Amazing product!" } }
        review.reload
        expect(review.rating).to eq(5)
        expect(review.comment).to eq("Amazing product!")
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq('Review was successfully updated.')
      end
    end

    context "when the review is invalid" do
      it "re-renders the edit form with errors" do
        sign_in buyer
        patch :update, params: { id: review.id, product_id: product.id, review: { rating: nil, comment: "" } }
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_present
      end
    end

    context "as a buyer editing another buyer's review" do
      let(:another_buyer) { create(:user, role: 'buyer') }
      let!(:other_review) { create(:review, user: another_buyer, product: product, rating: 3, comment: "Not bad") }

      it "does not allow updating another user's review and raises CanCan::AccessDenied" do
        sign_in buyer
        expect {
          patch :update, params: { id: other_review.id, product_id: product.id, review: { rating: 5, comment: "Trying to edit" } }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "DELETE #destroy" do
    context "as a buyer deleting own review" do
      it "deletes the review and redirects to the product page" do
        sign_in buyer
        expect {
          delete :destroy, params: { id: review.id, product_id: product.id }
        }.to change(Review, :count).by(-1)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq('Review was successfully deleted.')
      end
    end

    context "as a buyer deleting another buyer's review" do
      let(:another_buyer) { create(:user, role: 'buyer') }
      let!(:other_review) { create(:review, user: another_buyer, product: product) }

      it "does not allow deleting another user's review and raises CanCan::AccessDenied" do
        sign_in buyer
        expect {
          delete :destroy, params: { id: other_review.id, product_id: product.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
