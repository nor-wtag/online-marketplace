require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      username: "testuser",
      email: "testuser@example.com",
      password: "password123",
      phone: "01712345678",
      role: :buyer
    }
  end
  before do
    User.create!(valid_attributes)
  end

  describe 'validations for all user attributes including presence, uniqueness, format, and length constraints
            for username, email, phone number, role and password' do
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("test@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
    it { should validate_presence_of(:phone) }

    it { should allow_value("01712345678").for(:phone) }
    invalid_phone_numbers = [
      [ '11234567890', 'must start with 0 and contain exactly 11 digits' ],
      [ '0171234567', 'must start with 0 and contain exactly 11 digits' ],
      [ '0171234567890', 'must start with 0 and contain exactly 11 digits' ] ]

    invalid_phone_numbers.each do |phone, error_message|
      it "is invalid with phone number #{phone}" do
        user = User.new(valid_attributes.merge(phone: phone))
        expect(user).not_to be_valid
        expect(user.errors[:phone]).to include(error_message)
      end
    end
  end

  describe 'associations with related models' do
    it { should have_many(:products) }
    it { should have_many(:reviews) }
    it { should have_one(:cart) }
  end
end
