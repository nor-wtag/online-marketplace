# spec/requests/users/logout_spec.rb
require 'rails_helper'

RSpec.describe "User Log Out", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it "logs out the user" do
    delete destroy_user_session_path
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Sign In")
  end
end
