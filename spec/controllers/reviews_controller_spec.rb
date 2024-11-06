require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:product) { create(:product, user: seller) }
  let!(:review) { create(:review, user: buyer, product: product) }

  describe "GET #index of all the reviews" do
    context "as an admin" do
      it "allows access to all reviews" do
        sign_in admin
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:reviews)).to include(review)
      end
    end
  end

  describe "GET #show the products reviews" do
    context "as a buyer" do
      it "displays the review details" do
        sign_in buyer
        get :show, params: { id: review.id }
        expect(response).to render_template(:show)
        expect(assigns(:review)).to eq(review)
      end
    end

    context "as a seller" do
      it "allows access to review details for a product they own" do
        sign_in seller
        get :show, params: { id: review.id }
        expect(response).to render_template(:show)
        expect(assigns(:review)).to eq(review)
      end
    end
  end

  describe "GET #new for writing the reviews" do
    context "as a buyer" do
      it "renders the new review form" do
        sign_in buyer
        get :new, params: { product_id: product.id }
        expect(response).to render_template(:new)
        expect(assigns(:review)).to be_a_new(Review)
      end
    end
    context "as a seller" do
      it "does not render the new review form" do
        sign_in seller
        expect {
          get :new, params: { product_id: product.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "POST #create a review for the product" do
    context "when the reviewer is a buyer and the review is valid" do
      it "creates a new review and redirects to the product page" do
        sign_in buyer
        expect {
          post :create, params: { product_id: product.id, review: { rating: 4, comment: "Great product!" } }
        }.to change(Review, :count).by(1)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq('Review was successfully created.')
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
      get :edit, params: { id: review.id }
      expect(response).to render_template(:edit)
      expect(assigns(:review)).to eq(review)
    end
  end

  describe "PATCH #update" do
    context "when the review is valid and made by the buyer themself" do
      it "updates the review and redirects to the product page" do
        sign_in buyer
        patch :update, params: { id: review.id, review: { rating: 5, comment: "Amazing product!" } }
        review.reload
        expect(review.rating).to eq(5)
        expect(review.comment).to eq("Amazing product!")
        expect(response).to redirect_to(product_path(review.product))
        expect(flash[:notice]).to eq('Review was successfully updated.')
      end
    end

    context "when the review is invalid" do
      it "re-renders the edit form with errors" do
        sign_in buyer
        patch :update, params: { id: review.id, review: { rating: nil, comment: "" } }
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_present
      end
    end

    context "as a buyer editing another buyer's review" do
      let(:another_buyer) { create(:user, role: :buyer) }
      let!(:other_review) { create(:review, user: another_buyer, product: product, rating: 3, comment: "Not bad") }

      it "does not allow updating another user's review and raises CanCan::AccessDenied" do
        sign_in buyer
        expect {
          patch :update, params: { id: other_review.id, review: { rating: 5, comment: "Trying to edit" } }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "DELETE #destroy" do
    context "as a buyer deleting own review" do
      it "deletes the review and redirects to the product page" do
        sign_in buyer
        expect {
          delete :destroy, params: { id: review.id }
        }.to change(Review, :count).by(-1)
        expect(response).to redirect_to(product_path(review.product))
        expect(flash[:notice]).to eq('Review was successfully deleted.')
      end
    end

    context "as a buyer deleting another buyer's review" do
      let(:another_buyer) { create(:user, role: :buyer) }
      let!(:other_review) { create(:review, user: another_buyer, product: product) }

      it "does not allow deleting another user's review and raises CanCan::AccessDenied" do
        sign_in buyer
        expect {
          delete :destroy, params: { id: other_review.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
