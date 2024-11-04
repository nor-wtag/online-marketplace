class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  require 'cancan'
  def after_sign_up_path_for(resource)
    homepage_path
  end

  def after_sign_in_path_for(resource)
    homepage_path
  end

  def after_update_path_for(resource)
    homepage_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :phone, :role, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :email, :phone, :role, :password, :password_confirmation, :current_password ])
  end
end
