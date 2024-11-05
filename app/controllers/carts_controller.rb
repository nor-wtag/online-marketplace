class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  load_and_authorize_resource

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
end
