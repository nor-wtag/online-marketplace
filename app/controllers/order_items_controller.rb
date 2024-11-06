class OrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_item, only: [:show, :update]
  load_and_authorize_resource

  def show
  end

  def update
    # Only allow buyers to update their own order items
    if current_user.buyer? && @order_item.order.user == current_user
      if @order_item.update(order_item_params)
        redirect_to order_path(@order_item.order), notice: "Order item was successfully updated."
      else
        render :show, alert: "Failed to update the order item."
      end
    else
      redirect_to order_path(@order_item.order), alert: "You are not authorized to update this order item."
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
