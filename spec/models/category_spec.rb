require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations for name and description in Category model' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe 'association with products in Category model' do
    it { should have_and_belongs_to_many(:products) }
  end
end
