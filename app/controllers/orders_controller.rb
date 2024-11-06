# OrdersController
class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :cancel]
  load_and_authorize_resource except: [:create] # Exclude create action

  def index
    if current_user.buyer?
      @orders = current_user.orders
    elsif current_user.seller?
      @orders = Order.joins(order_items: :product).where(products: { user_id: current_user.id }).distinct
    else
      @orders = Order.none
    end
  end

  def show
  end

  def create
    if current_user.buyer?
      cart_items = current_user.cart.cart_items.includes(:product)
      total_price = cart_items.sum { |item| item.quantity * item.product.price }
      @order = current_user.orders.build(total_price: total_price, status: 'pending')

      if @order.save
        cart_items.each do |cart_item|
          @order.order_items.create!(
            product: cart_item.product,
            quantity: cart_item.quantity,
            price: cart_item.product.price
          )
        end
        current_user.cart.cart_items.destroy_all
        redirect_to @order, notice: "Order was successfully created."
      else
        redirect_to cart_path, alert: "Failed to create the order."
      end
    else
      redirect_to root_path, alert: "You are not authorized to create an order."
    end
  end

  def cancel
    if current_user.buyer? && @order.user == current_user
      @order.update(status: 'canceled')
      redirect_to orders_path, notice: "Order was successfully canceled."
    else
      redirect_to orders_path, alert: "You are not authorized to cancel this order."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
    if current_user.buyer?
      authorize! :read, @order
    elsif current_user.seller?
      # Sellers can only read orders containing their products
      raise CanCan::AccessDenied unless @order.order_items.any? { |item| item.product.user_id == current_user.id }
    end
  end
end
