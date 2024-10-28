class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!

  def index
    @products = Product.all
    @user = current_user
  end

  def show
  end

  def new
    @product = Product.new
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
    @product = Product.find(params[:id])
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

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: 'Product was successfully deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :stock)
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_users_path, alert: 'You need to sign in first.'
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
