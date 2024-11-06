class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_cart_item, only: [ :update, :destroy ]

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    if quantity > product.stock
      redirect_to cart_path, alert: 'Cannot add more than available stock.'
      return
    end

    existing_cart_item = @cart.cart_items.find_by(product_id: product.id)

    if existing_cart_item
      new_quantity = existing_cart_item.quantity + quantity
      if new_quantity > product.stock
        redirect_to cart_path, alert: 'Cannot add more than available stock.'
      else
        existing_cart_item.update(quantity: new_quantity)
        redirect_to cart_path, notice: 'Product quantity updated in cart.'
      end
    else
      @cart.cart_items.create(product: product, quantity: quantity)
      redirect_to cart_path, notice: 'Product added to cart.'
    end
  end
    # if existing_cart_item
    #   new_quantity = existing_cart_item.quantity + params[:quantity].to_i
    #   existing_cart_item.update(quantity: new_quantity)
    # else
    #   @cart.cart_items.create(product: product, quantity: params[:quantity] || 1)
    # end

    # redirect_to cart_path, notice: 'Product added to cart.'
    def update
      new_quantity = params[:quantity].to_i
      if new_quantity > @cart_item.product.stock
        redirect_to cart_path, alert: 'Cannot exceed available stock.'
      else
        if new_quantity > 0
          @cart_item.update(quantity: new_quantity)
        else
          @cart_item.destroy
        end
        redirect_to cart_path, notice: 'Cart item updated.'
      end
    end


  # def update
  #   if params[:quantity].to_i > 0
  #     @cart_item.update(quantity: params[:quantity])
  #   else
  #     @cart_item.destroy
  #   end
  #   redirect_to cart_path, notice: 'Cart item updated.'
  # end

  def destroy
    @cart_item.destroy
    redirect_to cart_path, notice: 'Item was removed from the cart.'
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: 'Cart item not found.'
  end
end
