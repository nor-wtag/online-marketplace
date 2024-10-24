require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe "associations" do
    it { should have_many(:category_products) }
    it { should have_many(:products).through(:category_products) }
  end
end
