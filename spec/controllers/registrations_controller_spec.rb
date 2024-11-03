# spec/controllers/registrations_controller_spec.rb
require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }

  before do
    sign_in user # Authenticate user
  end

  describe "PUT #update" do
    context "with valid attributes" do
      it "redirects to products_path after successful update" do
        put :update, params: { user: { username: "updated_username", email: user.email, current_password: "password123" } }
        
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('Your account has been updated successfully.')
      end
    end

    context "with invalid attributes" do
      it "re-renders the edit template" do
        put :update, params: { user: { email: "invalid-email", current_password: "password123" } }

        expect(response).to render_template(:edit)
      end
    end
  end
end
