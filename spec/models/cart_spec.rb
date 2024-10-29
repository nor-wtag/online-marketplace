require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'validation for user_id presence in Cart model' do
    it { should validate_presence_of(:user_id) }
  end

  describe 'associations with user and cart_items in Cart model' do
    it { should belong_to(:user) }
    it { should have_many(:cart_items) }
  end
end
