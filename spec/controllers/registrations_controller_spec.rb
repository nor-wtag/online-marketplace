require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  let(:user) { create(:user, email: "test@example.com", password: "password") }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "User creation with sign-up" do
    context "when creating a new user with valid values" do
      it "signs up a new user and redirects to homepage" do
        post :create, params: { user: attributes_for(:user, email: "newuser@example.com", password: "password", password_confirmation: "password") }
        new_user = User.find_by(email: "newuser@example.com")
        expect(new_user).not_to be_nil
        expect(response).to redirect_to(homepage_path)
      end
    end

    context "when creating a new user with invalid values" do
      it "does not sign up a new user with mismatched passwords" do
        post :create, params: { user: attributes_for(:user, email: "invaliduser@example.com", password: "password", password_confirmation: "differentpassword") }

        new_user = User.find_by(email: "invaliduser@example.com")
        expect(new_user).to be_nil
        expect(response).to render_template(:new)
        expect(assigns(:user).errors[:password_confirmation]).not_to be_empty
      end

      it "does not sign up a new user with missing email" do
        post :create, params: { user: attributes_for(:user, email: "", password: "password", password_confirmation: "password") }

        expect(User.find_by(email: "")).to be_nil
        expect(response).to render_template(:new)
        expect(assigns(:user).errors[:email]).not_to be_empty
      end
    end
  end

  describe "Profile Update" do
    context "when updating with current password" do
      context "with valid new password and confirmation" do
        it "updates the user with a new password" do
          controller.send(:update_resource, user, { current_password: "password", password: "newpassword", password_confirmation: "newpassword" })
          expect(user.reload.valid_password?("newpassword")).to be_truthy
        end
      end

      context "with valid non-password fields" do
        it "updates non-password fields successfully" do
          controller.send(:update_resource, user, { current_password: "password", username: "updateduser" })
          expect(user.reload.username).to eq("updateduser")
        end
      end

      context "with valid password but invalid non-password fields" do
        it "does not update the user if non-password fields are invalid" do
          controller.send(:update_resource, user, { current_password: "password", password: "newpassword", password_confirmation: "newpassword", email: "invalidemail" })
          expect(user.reload.valid_password?("newpassword")).to be_falsey
          expect(user.email).to eq("test@example.com")
          expect(user.errors[:email]).not_to be_empty
        end
      end
    end

    context "when updating without providing a new password or password confirmation" do
      it "allows updates to non-password fields without affecting the password" do
        allow(user).to receive(:update_without_password).and_call_original
        controller.send(:update_resource, user, { username: "updateduser", current_password: "" })
        expect(user).to have_received(:update_without_password).with(hash_including(username: "updateduser"))
        expect(user.reload.username).to eq("updateduser")
        expect(user.valid_password?("password")).to be_truthy
      end
    end

    context "with only invalid non-password fields" do
      it "does not update the user and returns an error" do
        result = controller.send(:update_resource, user, { email: "invalidemail", current_password: "" })
        expect(result).to be_falsey
        expect(user.reload.email).to eq("test@example.com")
        expect(user.errors[:email]).not_to be_empty
      end
    end
  end

  describe "Deleting a user account" do
    before do
      sign_in user
    end

    it "deletes the user account and redirects to root path" do
      delete :destroy
      expect(User.exists?(user.id)).to be_falsey
      expect(response).to redirect_to(root_path)
    end
  end
end
