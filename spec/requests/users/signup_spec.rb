# spec/requests/users/signup_spec.rb
require 'rails_helper'

RSpec.describe "User Sign Up", type: :request do
  it "allows a new user to sign up" do
    get new_user_registration_path
    expect(response).to render_template(:new)

    post user_registration_path, params: {
      user: {
        username: "newuser",
        email: "newuser@example.com",
        phone: "01712345678",
        role: "buyer",
        password: "password",
        password_confirmation: "password"
      }
    }
    expect(response).to redirect_to(products_path)
    follow_redirect!
    expect(response.body).to include("Welcome, newuser")
  end
end
