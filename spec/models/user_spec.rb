require 'rails_helper'

RSpec.describe User, type: :model do

  describe "validations" do
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value("test@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
    it { should validate_presence_of(:phone) }
    it { should validate_numericality_of(:phone).only_integer }
    it { should validate_presence_of(:role) }
    it { should define_enum_for(:role).with_values([:admin, :buyer, :seller, :rider]) }
  end

  describe "associations" do
    it { should have_many(:products) }
    it { should have_many(:reviews) }
    it { should have_one(:cart) }
  end
end
