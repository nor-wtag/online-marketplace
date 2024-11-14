require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Redirecting from sign up, sign in and signout processes" do
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
