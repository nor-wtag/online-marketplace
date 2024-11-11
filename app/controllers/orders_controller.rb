class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :cancel, :update_status]
  load_and_authorize_resource
  layout 'index'

  def index
    if current_user.buyer?
      # Buyers see only their own orders
      @orders = current_user.orders
    elsif current_user.seller?
      # Sellers see orders related to their products
      @orders = Order.joins(order_items: :product)
                     .where(products: { user_id: current_user.id }).distinct
    elsif current_user.rider?
      # Riders see orders where they are assigned to order items
      @orders = Order.joins(:order_items).where(order_items: { rider_id: current_user.id }).distinct
    elsif current_user.admin?
      # Admins see all orders, including orders with items set to "sent_to_delivery_company"
      @orders = Order.joins(:order_items)
                     .where(order_items: { status: 'sent_to_delivery_company' }).distinct
      Rails.logger.info "Admin Orders Retrieved: #{@orders.map(&:id)}" # Debugging line

    else
      # Default case: no orders visible
      @orders = Order.none
    end
  end
  

  def show
    @order.update_order_status!
    @order = Order.find(params[:id])

    if current_user.seller?
      # Seller view: only show order items related to seller's products
      @order_items = @order.order_items.joins(:product).where(products: { user_id: current_user.id })
    elsif current_user.rider?
      # Rider view: only show order items assigned to the rider
      @order_items = @order.order_items.where(rider_id: current_user.id)
    elsif current_user.admin?
      # Admin view: show all order items, focusing on "sent_to_delivery_company" items for assigning riders
      @order_items = @order.order_items
    else
      # Default for buyers and others: show all order items for the order
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
    @order_item = @order.order_items.find(params[:order_item_id])

    if current_user.admin? && @order_item.status == 'sent_to_delivery_company'
      # Admin can assign riders to order items with "sent_to_delivery_company" status
      @order_item.update(status: 'rider_assigned', rider_id: params[:rider_id])
      redirect_to order_path(@order), notice: 'Rider assigned successfully.'
    elsif current_user.seller? && @order_item.product.user_id == current_user.id
      # Seller updates statuses up to "sent_to_delivery_company"
      if %w[pending sent_to_delivery_company].include?(params[:status])
        @order_item.update(status: params[:status])
        @order.update_order_status!
        redirect_to order_path(@order), notice: 'Order item status updated successfully.'
      else
        redirect_to order_path(@order), alert: 'Sellers can only update status to Pending or Sent to Delivery Company.'
      end
    elsif current_user.rider? && @order_item.status == 'rider_assigned' && @order_item.rider_id == current_user.id
      # Rider marks as delivered
      @order_item.update(status: 'delivered')
      @order.update_order_status!
      redirect_to order_path(@order), notice: 'Order item marked as delivered.'
    elsif current_user.buyer? && @order_item.order.user == current_user && @order_item.status == 'delivered'
      # Buyer confirms receipt
      @order_item.update(status: 'received')
      @order.update_order_status!
      redirect_to order_path(@order), notice: 'Order item marked as received.'
    else
      redirect_to orders_path, alert: 'Unauthorized action.'
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
    authorize! :read, @order
  end
end
