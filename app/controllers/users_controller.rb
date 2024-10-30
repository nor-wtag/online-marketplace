class UsersController < ApplicationController
  layout 'index'

  before_action :set_user, only: [ :show, :edit, :update, :destroy, :delete ]
  before_action :require_login, only: [ :edit, :update, :destroy, :delete ]

  def index
    @user = User.new
    @users = User.all
  end

  def show
    @user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to sign_in_users_path, notice: 'User created successfully! Please sign in.'
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :new
    end
  end

  def sign_in
    @user = User.new
  end

  def create_session
    user = User.find_by(email: params[:email])
    if user&.authenticate_the_login(params[:password])
      session[:user_id] = user.id
      redirect_to products_path, notice: 'Successfully signed in!'
    else
      flash.now[:alert] = 'Invalid email or password'
      render :sign_in
    end
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to sign_in_users_path, notice: 'Successfully signed out!'
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to products_path, notice: 'User updated successfully!'
    else
      render :edit
    end
  end

  def delete
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = 'User deleted successfully.'
    redirect_to users_path
  end


  def products
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    redirect_to users_path, alert: 'User not found' unless @user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :phone, :role)
  end

  def require_login
    redirect_to sign_in_users_path, alert: 'Please sign in first' unless session[:user_id]
  end
end
