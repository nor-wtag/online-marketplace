require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:product) { create(:product, user: seller) }
  let(:category) { create(:category) }

  context "when the user is an admin" do
    subject(:ability) { Ability.new(admin) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context "when the user is a seller" do
    subject(:ability) { Ability.new(seller) }

    it { is_expected.to be_able_to(:create, Product) }
    it { is_expected.to be_able_to(:read, Product) }
    it { is_expected.to be_able_to(:update, product) }
    it { is_expected.to be_able_to(:destroy, product) }
    it { is_expected.not_to be_able_to(:create, Category) }
    it { is_expected.to be_able_to(:read, Category) }
  end

  context "when the user is a buyer" do
    subject(:ability) { Ability.new(buyer) }

    it { is_expected.to be_able_to(:read, Product) }
    it { is_expected.to be_able_to(:read, Category) }
    it { is_expected.not_to be_able_to(:create, Product) }
    it { is_expected.not_to be_able_to(:destroy, product) }
  end
end
