require 'rails_helper'

RSpec.describe Cart do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:cart_items) }
  end
end
