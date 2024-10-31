class UsersController < ApplicationController
  layout 'index'

  before_action :set_user, only: [ :edit, :update ]
  before_action :authenticate_user!, except: [ :index ]

  def index
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to products_path, notice: 'User updated successfully!'
    else
      render :edit
    end
  end

  # def destroy
  #   @user.destroy
  #   flash[:notice] = 'User deleted successfully.'
  #   redirect_to users_path
  # end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :phone, :role, :password, :password_confirmation)
  end
end
