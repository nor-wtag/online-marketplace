class UsersController < ApplicationController
  layout 'index'

  before_action :set_user, only: [ :show, :edit, :update, :destroy, :delete ]
  before_action :require_login, only: [ :edit, :update, :destroy, :delete ]

  def index
    @user = User.new
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to sign_in_users_path, notice: t('users.create_success')
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
      redirect_to products_path, notice: t('users.sign_in_success')
    else
      flash.now[:alert] = t('users.invalid_credentials')
      render :sign_in
    end
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to sign_in_users_path, notice: t('users.sign_out_success')
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to products_path, notice: t('users.update_success')
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :edit
    end
  end

  def delete
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: t('users.delete_success')
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    redirect_to users_path, alert: t('users.not_found') unless @user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :phone, :role)
  end

  def require_login
    redirect_to sign_in_users_path, alert: t('users.require_login') unless session[:user_id]
  end
end
