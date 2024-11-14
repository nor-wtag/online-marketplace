class ReviewsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_product, only: [ :new, :create, :edit, :update, :destroy, :delete ]
  before_action :set_review, only: [ :edit, :update, :destroy, :delete ]
  layout 'index'

  def show
    @reviews = Review.all
  end

  def new
    unless purchased_product?
      redirect_to product_path(@product), alert: t('reviews.alerts.not_purchased')
      return
    end

    @review = @product.reviews.build
  end

  def create
    unless purchased_product?
      redirect_to product_path(@product), alert: t('reviews.alerts.not_purchased')
      return
    end

    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product), notice: t('reviews.notices.created')
    else
      flash.now[:alert] = @review.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    unless current_user == @review.user
      redirect_to product_path(@product), alert: t('reviews.alerts.not_owner_edit')
    end
  end

  def update
    if current_user != @review.user
      flash[:alert] = t('reviews.alerts.not_owner_update')
      redirect_to product_path(@product)
      return
    end

    if @review.update(review_params)
      redirect_to product_path(@product), notice: t('reviews.notices.updated')
    else
      flash.now[:alert] = @review.errors.full_messages.join(', ')
      render :edit
    end
  end

  def delete
  end

  def destroy
    if current_user == @review.user
      @review.destroy
      redirect_to product_path(@product), notice: t('reviews.notices.deleted')
    else
      flash[:alert] = t('reviews.alerts.not_owner_delete')
      redirect_to product_path(@product)
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def purchased_product?
    return false unless current_user.buyer?
    @product.order_items.joins(:order).where(
      orders: { user_id: current_user.id },
      status: 'received'
    ).exists?
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
