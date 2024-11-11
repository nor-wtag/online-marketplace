require 'rails_helper'

RSpec.describe User do
  let(:valid_attributes) do
    {
      username: "testuser",
      email: "testuser@example.com",
      phone: "01712345678",
      role: :buyer,
      password: "password123"
    }
  end

  describe 'validations for user attributes including presence, uniqueness, format, and length constraints' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it 'validates presence of email' do
      user = User.new(email: nil)
      user.valid?
      expect(user.errors[:email]).to include(I18n.t('errors.messages.blank'))
    end
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
    it { is_expected.to validate_presence_of(:phone) }

    it { is_expected.to allow_value('01712345678').for(:phone) }

    invalid_phone_numbers = [ '11234567890', '0171234567', '0171234567890' ]

    invalid_phone_numbers.each do |phone|
      it 'is invalid with phone number #{phone}' do
        user = User.new(valid_attributes.merge(phone: phone))
        expect(user).not_to be_valid
        expect(user.errors[:phone]).to be_present
      end
    end
  end

  describe 'roles' do
    it { should define_enum_for(:role).with_values(admin: 0, buyer: 1, seller: 2, rider: 3) }

    context 'Correct role assignments' do
      it 'assigns admin role correctly' do
        user = create(:user, role: 'admin')
        expect(user).to be_admin
      end

      it 'assigns seller role correctly' do
        user = create(:user, role: 'seller')
        expect(user).to be_seller
      end

      it 'assigns buyer role correctly' do
        user = create(:user, role: 'buyer')
        expect(user).to be_buyer
      end

      it 'assigns rider role correctly' do
        user = create(:user, role: 'rider')
        expect(user).to be_rider
      end
    end
  end

  describe 'roles' do
    it { should define_enum_for(:role).with_values(admin: 0, buyer: 1, seller: 2, rider: 3) }

    context 'Correct role assignments' do
      it 'assigns admin role correctly' do
        user = create(:user, role: 'admin')
        expect(user).to be_admin
      end

      it 'assigns seller role correctly' do
        user = create(:user, role: 'seller')
        expect(user).to be_seller
      end

      it 'assigns buyer role correctly' do
        user = create(:user, role: 'buyer')
        expect(user).to be_buyer
      end

      it 'assigns rider role correctly' do
        user = create(:user, role: 'rider')
        expect(user).to be_rider
      end
    end
  end

  describe 'associations with related models' do
    it { is_expected.to have_many(:products) }
    it { is_expected.to have_many(:reviews) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_one(:cart) }
  end
end
