class OrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_item, only: [ :show, :update, :update_status ]
  load_and_authorize_resource
  layout 'index'

  def show
  end

  def update
    if current_user.buyer? && @order_item.order.user == current_user
      if @order_item.update(order_item_params)
        redirect_to order_path(@order_item.order), notice: 'Order item was successfully updated.'
      else
        render :show, alert: 'Failed to update the order item.'
      end
    else
      redirect_to order_path(@order_item.order), alert: 'You are not authorized to update this order item.'
    end
  end

  def update_status
    if current_user.seller? && current_user == @order_item.product.user
      if @order_item.update(status: params[:order_item][:status])
      # if @order_item.update(status: params[:status])
        @order_item.order.update_order_status!
        redirect_to order_path(@order_item.order), notice: 'Order item status updated successfully.'
      else
        redirect_to order_path(@order_item.order), alert: 'Failed to update order item status.'
      end
    else
      redirect_to root_path, alert: 'You are not authorized to update this item.'
    end
  end
  

  private

  def set_order_item
    @order_item = OrderItem.find(params[:id])
    authorize! :read, @order_item
  end

  def order_item_params
    params.require(:order_item).permit(:quantity, :price)
  end
end
