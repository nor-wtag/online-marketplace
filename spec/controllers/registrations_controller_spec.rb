require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user, email: "test@example.com", password: "password") }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "User creation with sign-up" do
    context "when creating a new user with valid values" do
      it "signs up a new user and redirects to homepage" do
        post :create, params: { user: { email: "newuser@example.com", password: "password", password_confirmation: "password", role: "buyer", phone: "01999999999" } }

        new_user = User.find_by(email: "newuser@example.com")
        puts "Response Body: #{response.body}"
        puts "User Count: #{User.count}"
        expect(new_user).not_to be_nil
        expect(response).to redirect_to(homepage_path)
        end
      end

    context "when creating a new user with invalid values" do
      it "does not sign up a new user with mismatched passwords" do
        post :create, params: { user: { email: "invaliduser@example.com", password: "password", password_confirmation: "differentpassword" } }
        new_user = User.find_by(email: "invaliduser@example.com")
        expect(new_user).to be_nil
        expect(response).to render_template(:new)
        expect(assigns(:user).errors[:password_confirmation]).not_to be_empty
      end
    end
  end

  describe "PATCH #update_profile" do
    before { sign_in user }

    context "when updating without changing password" do
      it "updates non-password fields successfully" do
        patch :update_profile, params: { user: { username: "updateduser", current_password: "" } }
        expect(user.reload.username).to eq("updateduser")
        expect(response).to redirect_to(homepage_path)
      end
    end

    context "when updating with invalid email" do
      it "fails to update and renders edit with error messages" do
        patch :update_profile, params: { user: { email: "" } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "Deleting a user account by the user" do
    before { sign_in user }

    it "deletes the user account and redirects to root path" do
      allow(controller).to receive(:after_sign_out_path_for).and_return(root_path)
      delete :destroy
      expect(User.exists?(user.id)).to be_falsey
      expect(response).to redirect_to(root_path)
    end
  end
end
