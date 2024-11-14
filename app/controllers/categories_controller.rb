class CategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_category, only: [ :show, :edit, :update, :destroy, :delete ]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_index_with_alert
  layout 'index'

  def index
    @categories = Category.all
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: t('categories.category_created')
    else
      flash.now[:alert] = @category.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: t('categories.category_updated')
    else
      flash.now[:alert] = @category.errors.full_messages.join(', ')
      render :edit
    end
  end

  def delete
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to categories_path, notice: t('categories.category_deleted')
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to_index_with_alert
  end

  def redirect_to_index_with_alert
    redirect_to categories_path, alert: t('categories.not_found')
  end

  def category_params
    params.require(:category).permit(:name, :description, product_ids: [])
  end
end
