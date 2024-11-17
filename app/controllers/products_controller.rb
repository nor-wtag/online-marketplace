class ProductsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  layout 'index'
  before_action :set_product, only: [ :show, :edit, :update, :destroy, :delete ]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_index_with_alert


  def index
    @products = Product.all
    @user = current_user
  end
  def new
    authorize! :create, Product
    @product = Product.new
  end

  def show
    @reviews = @product.reviews.includes(:user)
  end

  def create
    authorize! :create, Product
    @product = Product.new(product_params)
    @product.seller = current_user
    if @product.save
      redirect_to products_path, notice: t('products.product_created')
    else
      flash.now[:alert] = @product.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    authorize! :update, Product
    @product
  end

  def update
    authorize! :update, Product

    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to products_path, notice: t('products.product_updated')
    else
      flash.now[:alert] = @product.errors.full_messages.join(', ')
      render :edit
    end
  end

  def delete
  end

  def destroy
    authorize! :destroy, Product

    @product = Product.find(params[:id])
    @product.transaction do
      @product.order_items.update_all(availibility: 'unavailable')
      @product.order_items.each do |order_item|
        order_item.order.recalculate_total_price
      end
      @product.destroy
    end
    redirect_to products_path, notice: t('products.product_deleted')
  end

  private
  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to_index_with_alert
  end

  def redirect_to_index_with_alert
    redirect_to products_path, alert: t('products.not_found')
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :stock, :image, category_ids: [])
  end
end
