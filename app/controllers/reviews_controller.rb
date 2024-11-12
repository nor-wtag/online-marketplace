class ReviewsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_product, only: [:new, :create, :edit, :update, :destroy, :delete]
  before_action :set_review, only: [:edit, :update, :destroy, :delete]
  
  def show
    @reviews=Review.all
  end

  def new
    unless purchased_product?
      redirect_to product_path(@product), alert: 'You can only review products you have purchased.'
      return
    end

    @review = @product.reviews.build
  end

  def create
    unless purchased_product?
      redirect_to product_path(@product), alert: 'You can only review products you have purchased.'
      return
    end

    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product), notice: 'Review was successfully created.'
    else
      flash.now[:alert] = @review.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit

  end

  def update
    if @review.update(review_params)
      redirect_to product_path(@product), notice: 'Review was successfully updated.'
    else
      flash.now[:alert] = @review.errors.full_messages.join(', ')
      render :edit
    end
  end

  def delete
  end

  def destroy
    @review = @product.reviews.find(params[:id])
    @review.destroy
    redirect_to product_path(@product), notice: 'Review was successfully deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def purchased_product?
    current_user.buyer? && @product.orders.where(user_id: current_user.id, status: 'completed').exists?
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
