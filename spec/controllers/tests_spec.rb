require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  let(:buyer1) { create(:user, username: "buyer1", email: "buyer1@example.com", password: "password", role: "buyer") }
  let(:buyer2) { create(:user, username: "buyer2", email: "buyer2@example.com", password: "password", role: "buyer") }

  before { sign_in buyer1 }

  it "prevents buyer1 from updating buyer2's email" do
    # Explicitly check permissions to isolate the issue
    ability = Ability.new(buyer1)
    expect(ability.can?(:update, buyer2)).to be_falsey

    # Attempt update and expect CanCan::AccessDenied
    expect {
      put :update, params: { id: buyer2.id, user: { email: "unauthorized@example.com" } }
    }.to raise_error(CanCan::AccessDenied)

    # Ensure email remains unchanged
    expect(buyer2.reload.email).to eq("buyer2@example.com")
  end
end
