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
    @product = Product.new
  end

  def show
    @product
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user
    if @product.save
      redirect_to products_path, notice: 'Product was successfully created.'
    else
      flash.now[:alert] = @product.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @product
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to products_path, notice: 'Product was successfully updated.'
    else
      flash.now[:alert] = @product.errors.full_messages.join(', ')
      render :edit
    end
  end

  def delete
  end
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: 'Product was successfully deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found'
  end
  
  def redirect_to_index_with_alert
    redirect_to products_path, alert: 'Product not found'
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :stock, category_ids: [])
  end
end
