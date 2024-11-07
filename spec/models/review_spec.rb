require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'validations for rating and comment presence, and rating value constraints' do
    it { should validate_presence_of(:rating) }
    it { should validate_inclusion_of(:rating).in_range(1..5) }
    it { should validate_presence_of(:comment) }
  end

  describe 'associations with user and product models' do
    it { should belong_to(:user) }
    it { should belong_to(:product) }
  end
end
