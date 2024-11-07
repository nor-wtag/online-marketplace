class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :cancel, :update_status ]
  load_and_authorize_resource
  layout 'index'
  
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
    @order.update_order_status!
    @order = Order.find(params[:id])
    if current_user.seller?
      @order_items = @order.order_items.joins(:product).where(products: { user_id: current_user.id })
    else
      @order_items = @order.order_items
    end
  end

  def create
    if current_user.buyer?
      cart_items = current_user.cart.cart_items.includes(:product)
      total_price = cart_items.sum { |item| item.quantity * item.product.price }

      @order = current_user.orders.build(total_price: total_price, status: 'pending')

      if @order.save
        cart_items.each do |cart_item|
          product = cart_item.product
          if product.stock >= cart_item.quantity
            product.update(stock: product.stock - cart_item.quantity)
            @order.order_items.create!(
              product: product,
              quantity: cart_item.quantity,
              price: product.price
            )
          else
            @order.destroy
            redirect_to cart_path, alert: "Insufficient stock for #{product.title}. Order could not be created." and return
          end
        end

        current_user.cart.cart_items.destroy_all
        redirect_to @order, notice: 'Order was successfully created.'
      else
        redirect_to cart_path, alert: 'Failed to create the order.'
      end
    else
      redirect_to root_path, alert: 'You are not authorized to create an order.'
    end
  end

  def cancel
    if current_user.buyer? && @order.user == current_user
      @order.update(status: 'cancelled')
      redirect_to orders_path, notice: 'Order was successfully cancelled.'
    else
      redirect_to orders_path, alert: 'You are not authorized to cancel this order.'
    end
  end

  def update_status
    if current_user.seller?
      @order_item = @order.order_items.find(params[:order_item_id])
      if @order_item.product.user_id == current_user.id
        @order_item.update(status: params[:status])
        @order.update_order_status!
        redirect_to order_path(@order), notice: 'Order item status updated successfully.'
      else
        redirect_to orders_path, alert: 'You are not authorized to update this order item.'
      end
    else
      redirect_to orders_path, alert: 'You are not authorized to update order items.'
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
    authorize! :read, @order
  end
end
