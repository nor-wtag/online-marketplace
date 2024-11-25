class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :update_status ]
  load_and_authorize_resource
  layout 'index'
  
  def index
    if current_user.buyer?
      @orders = current_user.orders
    elsif current_user.seller?
      @orders = Order.joins(order_items: :product)
                     .where(products: { user_id: current_user.id }).distinct
    elsif current_user.rider?
      @orders = Order.joins(:order_items).where(order_items: { rider_id: current_user.id }).distinct
    elsif current_user.admin?
      @orders = Order.joins(:order_items)
                     .where(order_items: { status: 'sent_to_delivery_company' }).distinct
    else
      @orders = Order.none
    end
  end

  def show
    @order.update_order_status!
    @order = Order.find(params[:id])

    if current_user.seller?
      @order_items = @order.order_items.joins(:product).where(products: { user_id: current_user.id })
    elsif current_user.rider?
      @order_items = @order.order_items.where(rider_id: current_user.id)
    elsif current_user.admin?
      @order_items = @order.order_items
    else
      @order_items = @order.order_items
    end
  end

  def create
    if current_user.buyer?
      cart_items = current_user.cart.cart_items.includes(:product)
      total_price = cart_items.sum { |item| item.quantity * item.product.price }
      insufficient_product = nil
      begin
        ActiveRecord::Base.transaction do
          @order = current_user.orders.build(total_price: total_price, status: 'pending')
          cart_items.each do |cart_item|
            product = cart_item.product
            if product.stock >= cart_item.quantity
              product.update!(stock: product.stock - cart_item.quantity)
              @order.order_items.build(
                product: product,
                quantity: cart_item.quantity,
                price: product.price
              )
            else
              insufficient_product = product
              raise ActiveRecord::Rollback
            end
          end
          if @order.save
            cart_items.destroy_all
            SendOrderConfirmationJob.perform_later(@order.id)
            redirect_to @order, notice: t('orders.created')
          else
            flash[:alert] = t('orders.creation_failed')
            redirect_to cart_path
          end
        end
      rescue ActiveRecord::Rollback
        product_title = insufficient_product ? insufficient_product.title : t('orders.unknown_product')
        flash[:alert] = t('orders.insufficient_stock', title: product_title)
        redirect_to cart_path
      end
    else
      flash[:alert] = t('orders.unauthorized_creation')
      redirect_to root_path
    end
  end

  def update_status
    @order_item = @order.order_items.find(params[:order_item_id])

    if current_user.admin? && @order_item.status == 'sent_to_delivery_company'
      @order_item.update(status: 'rider_assigned', rider_id: params[:rider_id])
      redirect_to order_path(@order), notice: t('orders.rider_assigned')
    elsif current_user.seller? && @order_item.product.user_id == current_user.id
      if %w[pending sent_to_delivery_company].include?(params[:status])
        @order_item.update(status: params[:status])
        @order.update_order_status!
        redirect_to order_path(@order), notice: t('orders.status_updated')
      else
        redirect_to order_path(@order), alert: t('orders.seller_status_limit')
      end
    elsif current_user.rider? && @order_item.status == 'rider_assigned' && @order_item.rider_id == current_user.id
      @order_item.update(status: 'delivered')
      @order.update_order_status!
      redirect_to order_path(@order), notice: t('orders.delivered')
    elsif current_user.buyer? && @order_item.order.user == current_user && @order_item.status == 'delivered'
      @order_item.update(status: 'received')
      @order.update_order_status!
      redirect_to order_path(@order), notice: t('orders.received')
    else
      redirect_to orders_path, alert: t('orders.unauthorized_action')
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
    authorize! :read, @order
  end
end
