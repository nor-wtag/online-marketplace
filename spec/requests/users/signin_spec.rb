# spec/requests/users/signin_spec.rb
require 'rails_helper'

RSpec.describe "User Sign In", type: :request do
  let(:user) { create(:user) }

  it "allows an existing user to sign in" do
    get new_user_session_path
    expect(response).to render_template(:new)

    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password
      }
    }

    expect(response).to redirect_to(products_path)
    follow_redirect!
    expect(response.body).to include("Welcome, #{user.username}")
  end
end
