class UsersController < ApplicationController
  layout 'index'
  before_action :set_user, only: [ :new, :create ]
  before_action :authenticate_user!, only: [ :products ]

  def index
    @user = User.new
  end

  def new
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
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to products_path, notice: 'Successfully signed in!'
    else
      flash.now[:alert] = 'Invalid email or password'
      render :sign_in
    end
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to root_path, notice: 'Successfully signed out!'
  end

  def products
  end

  private

  def set_user
    if action_name =='create'
      @user = User.new(user_params)
    else
      @user = User.new
    end
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_users_path, alert: 'You need to sign in first.'
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :phone, :role)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end


def edit
  @user = User.find(params[:id])
end

def update
  @user = User.find(params[:id])
  if @user.update(user_params)
    redirect_to users_path, notice: 'User updated successfully!'
  else
    render :edit
  end
end

def delete
  @user = User.find(params[:id])
end

def destroy
  @user = User.find(params[:id])
  @user.destroy
  flash[:notice] = 'User deleted'
  redirect_to users_path
end
