require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:user, role: 'admin') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:seller) { create(:user, role: 'seller') }
  let(:product) { create(:product, user: seller) }
  let(:order) { create(:order, user: buyer, status: 'completed') }
  let!(:order_item) { create(:order_item, order: order, product: product, status: 'received') }
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
    context "as a buyer with an order_item status of 'received'" do
      it "renders the new review form" do
        sign_in buyer
        get :new, params: { product_id: product.id }
        expect(response).to render_template(:new)
        expect(assigns(:review)).to be_a_new(Review)
      end
    end

    context "as a buyer with no order_item status of 'received'" do
      before do
        order_item.update(status: 'pending')
        allow_any_instance_of(ReviewsController).to receive(:purchased_product?).and_return(false)
      end

      it "redirects with an alert" do
        sign_in buyer
        get :new, params: { product_id: product.id }
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq(I18n.t('reviews.alerts.not_purchased'))
      end
    end
  end

  describe "POST #create" do
    context "as a buyer with an order_item status of 'received'" do
      it "creates a new review and redirects to the product page" do
        sign_in buyer
        expect {
          post :create, params: { product_id: product.id, review: { rating: 4, comment: "Great product!" } }
        }.to change(Review, :count).by(1)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq(I18n.t('reviews.notices.created'))
      end
    end

    context "as a buyer with no order_item status of 'received'" do
      before do
        allow_any_instance_of(ReviewsController).to receive(:purchased_product?).and_return(false)
      end

      it "does not create a review and redirects with an alert" do
        sign_in buyer
        expect {
          post :create, params: { product_id: product.id, review: { rating: 4, comment: "Great product!" } }
        }.not_to change(Review, :count)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq(I18n.t('reviews.alerts.not_purchased'))
      end
    end
  end

  describe "GET #edit" do
    context "as the owner of the review" do
      it "renders the edit form" do
        sign_in buyer
        get :edit, params: { id: review.id, product_id: product.id }
        expect(response).to render_template(:edit)
        expect(assigns(:review)).to eq(review)
      end
    end

    context "as not the owner of the review" do
      let(:another_buyer) { create(:user, role: 'buyer') }

      it "redirects with an alert" do
        sign_in another_buyer
        get :edit, params: { id: review.id, product_id: product.id }
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq(I18n.t('reviews.alerts.not_owner_edit'))
      end
    end
  end

  describe "PATCH #update" do
    context "as the owner of the review" do
      it "updates the review and redirects to the product page" do
        sign_in buyer
        patch :update, params: { id: review.id, product_id: product.id, review: { rating: 5, comment: "Amazing product!" } }
        review.reload
        expect(review.rating).to eq(5)
        expect(review.comment).to eq("Amazing product!")
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq(I18n.t('reviews.notices.updated'))
      end
    end

    context "as not the owner of the review" do
      let(:another_buyer) { create(:user, role: 'buyer') }

      it "redirects with an alert" do
        sign_in another_buyer
        patch :update, params: { id: review.id, product_id: product.id, review: { rating: 5, comment: "Not allowed!" } }
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq(I18n.t('reviews.alerts.not_owner_update'))
      end
    end
  end

  describe "DELETE #destroy" do
    context "as the owner of the review" do
      it "deletes the review and redirects to the product page" do
        sign_in buyer
        expect {
          delete :destroy, params: { id: review.id, product_id: product.id }
        }.to change(Review, :count).by(-1)
        expect(response).to redirect_to(product_path(product))
        expect(flash[:notice]).to eq(I18n.t('reviews.notices.deleted'))
      end
    end

    context "as not the owner of the review" do
      let(:another_buyer) { create(:user, role: 'buyer') }

      it "redirects with an alert" do
        sign_in another_buyer
        delete :destroy, params: { id: review.id, product_id: product.id }
        expect(response).to redirect_to(product_path(product))
        expect(flash[:alert]).to eq(I18n.t('reviews.alerts.not_owner_delete'))
      end
    end
  end
end
