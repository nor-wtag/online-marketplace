class ReviewsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_product, only: [ :new, :create ]
  before_action :set_review, only: [ :show, :edit, :update, :destroy ]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_index_with_alert

  def index
    @reviews = Review.all
  end

  def show; end

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product), notice: 'Review was successfully created.'
    else
      flash.now[:alert] = @review.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit; end

  def update
    if @review.update(review_params)
      redirect_to product_path(@review.product), notice: 'Review was successfully updated.'
    else
      flash.now[:alert] = @review.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to product_path(@review.product), notice: 'Review was successfully deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = Review.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to reviews_path, alert: 'Review not found'
  end

  def redirect_to_index_with_alert
    redirect_to reviews_path, alert: 'Review not found'
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
