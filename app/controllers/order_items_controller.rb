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
        redirect_to order_path(@order_item.order), notice: t('order_items.status_updated')
      else
        redirect_to order_path(@order_item.order), alert: t('order_items.seller_status_limit')
      end
    elsif current_user.buyer? && current_user == @order_item.order.user
      if params[:status] == 'received'
        @order_item.update(status: params[:status])
        @order_item.order.update_order_status!
        redirect_to order_path(@order_item.order), notice: t('order_items.received')
      else
        redirect_to order_path(@order_item.order), alert: t('order_items.buyer_status_limit')
      end
    else
      redirect_to root_path, alert: t('order_items.unauthorized_update')
    end
  end

  def update_status
    @order_item = OrderItem.find(params[:id])
    if current_user.buyer? && @order_item.status == 'delivered' && @order_item.order.user == current_user
      authorize! :update_status, @order_item
      @order_item.update!(status: 'received')
      @order_item.order.update_order_status!
      redirect_to order_path(@order_item.order), notice: t('order_items.received')

    elsif current_user.rider? && @order_item.status == 'rider_assigned' && @order_item.rider_id == current_user.id
      authorize! :update_status, @order_item
      @order_item.update!(status: 'delivered')
      redirect_to order_path(@order_item.order), notice: t('order_items.delivered')

    elsif current_user.seller? && current_user == @order_item.product.user && %w[pending sent_to_delivery_company].include?(params[:status])
      authorize! :update_status, @order_item
      @order_item.update!(status: params[:status])
      redirect_to order_path(@order_item.order), notice: t('order_items.status_updated')

    elsif current_user.admin? && params[:status] == 'rider_assigned' && params[:rider_id].present?
      authorize! :update_status, @order_item
      @order_item.update(status: 'rider_assigned', rider_id: params[:rider_id])
      redirect_to order_path(@order_item.order), notice: t('order_items.rider_assigned')

    else
      redirect_to root_path, alert: t('order_items.unauthorized_update')
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
