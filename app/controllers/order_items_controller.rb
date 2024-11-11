class OrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_item, only: [ :show, :update, :update_status ]
  load_and_authorize_resource
  layout 'index'

  def show
  end

  def update
    if current_user.seller? && current_user == @order_item.product.user
      if %w[pending sent_to_delivery_company rider_assigned].include?(params[:status])
        @order_item.update(status: params[:status])
        @order_item.order.update_order_status!
        redirect_to order_path(@order_item.order), notice: 'Order item status updated successfully.'
      else
        redirect_to order_path(@order_item.order), alert: 'Sellers can only update status to Pending, Sent to Delivery Company, or Rider Assigned.'
      end
    elsif current_user.buyer? && current_user == @order_item.order.user
      if params[:status] == 'received'
        @order_item.update(status: params[:status])
        @order_item.order.update_order_status!
        redirect_to order_path(@order_item.order), notice: 'Order item marked as received.'
      else
        redirect_to order_path(@order_item.order), alert: 'Buyers can only mark the item as received.'
      end
    else
      redirect_to root_path, alert: 'You are not authorized to update this item.'
    end
  end

  def update_status
    @order_item = OrderItem.find(params[:id])

    if current_user.buyer? && @order_item.status == 'delivered' && @order_item.order.user == current_user
      # Buyer marking as received
      if @order_item.update(status: 'received')
        @order_item.order.update_order_status! # Check if order should be completed
        redirect_to order_path(@order_item.order), notice: 'Order item marked as received.'
      else
        redirect_to order_path(@order_item.order), alert: 'Failed to update order item status.'
      end

    elsif current_user.rider? && @order_item.status == 'rider_assigned' && @order_item.rider_id == current_user.id
      # Rider marking as delivered
      if @order_item.update(status: 'delivered')
        redirect_to order_path(@order_item.order), notice: 'Order item marked as delivered.'
      else
        redirect_to order_path(@order_item.order), alert: 'Failed to update order item status.'
      end

    else
      redirect_to root_path, alert: 'You are not authorized to update this item.'
    end
  end

  #   if current_user.seller? && current_user == @order_item.product.user
  #     if @order_item.update(status: params[:status])
  #       @order_item.order.update_order_status!
  #       redirect_to order_path(@order_item.order), notice: 'Order item status updated successfully.'
  #     else
  #       redirect_to order_path(@order_item.order), alert: 'Failed to update order item status.'
  #     end
  #   else
  #     redirect_to root_path, alert: 'You are not authorized to update this item.'
  #   end
  # end

  # def update_status
  #   if current_user.seller? && current_user == @order_item.product.user
  #     if @order_item.update(status: params[:order_item][:status])
  #     # if @order_item.update(status: params[:status])
  #       @order_item.order.update_order_status!
  #       redirect_to order_path(@order_item.order), notice: 'Order item status updated successfully.'
  #     else
  #       redirect_to order_path(@order_item.order), alert: 'Failed to update order item status.'
  #     end
  #   else
  #     redirect_to root_path, alert: 'You are not authorized to update this item.'
  #   end
  # end
  

  private

  def set_order_item
    @order_item = OrderItem.find(params[:id])
    authorize! :read, @order_item
  end

  def order_item_params
    params.require(:order_item).permit(:quantity, :price)
  end
end
