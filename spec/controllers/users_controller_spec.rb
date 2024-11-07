require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Redirecting from sign up, sign in and signout processes" do
    context "when signing in" do
      it "signs in the user and redirects to homepage" do
        sign_in user
        get :homepage
        expect(response).to render_template(:homepage)
      end

      it "signs out the user and redirects to root path" do
        sign_in user
        sign_out user
        get :homepage
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    it "redirects to homepage after sign up" do
      expect(controller.send(:after_sign_up_path_for, user)).to eq(homepage_path)
    end

    it "redirects to homepage after sign in" do
      expect(controller.send(:after_sign_in_path_for, user)).to eq(homepage_path)
    end

    it "redirects to homepage after account update" do
      expect(controller.send(:after_update_path_for, user)).to eq(homepage_path)
    end

    it "redirects to root after sign out" do
      expect(controller.send(:after_sign_out_path_for, user)).to eq(root_path)
    end
  end
end
