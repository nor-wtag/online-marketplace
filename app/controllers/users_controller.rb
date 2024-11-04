class UsersController < ApplicationController
  layout 'index'

  before_action :authenticate_user!, except: [ :index ]

  def index
    @user = User.new
  end

  def homepage
    @products = Product.all
    @categories = Category.all
  end
end
