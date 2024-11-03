class ProductsController < ApplicationController
  before_action :authenticate_user!
  layout 'index'
  before_action :set_product, only: [ :show, :edit, :update, :destroy, :delete ]
  
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

  def product_params
    params.require(:product).permit(:title, :description, :price, :stock, category_ids: [])
  end

  # def authenticate_user!
  #   unless current_user
  #     redirect_to sign_in_users_path, alert: 'You need to sign in first.'
  #   end
  # end

  # def current_user
  #   @current_user ||= User.find_by(id: session[:user_id])
  # end
end