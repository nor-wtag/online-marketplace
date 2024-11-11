class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  require 'cancan'

  # rescue_from CanCan::AccessDenied do |exception|
  #   flash[:alert] = exception.message
  #   redirect_to root_path
  # end
  #
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to new_user_session_path(locale: I18n.locale), alert: 'Session expired. Please sign in again.'
  end
  
  def default_url_options
    { locale: I18n.locale }
  end

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    Rails.env.test? ? {} : { locale: I18n.locale.presence || I18n.default_locale }
  end

  def after_sign_in_path_for(resource)
    homepage_path(locale: I18n.locale)
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path(locale: I18n.locale)
  end

  def after_sign_up_path_for(resource)
    homepage_path(locale: I18n.locale)
  end

  def after_update_path_for(resource)
    homepage_path(locale: I18n.locale)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :phone, :role, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :email, :phone, :role, :password, :password_confirmation, :current_password ])
  end
  # 

  # def set_locale
  #   I18n.locale = params[:locale] || I18n.default_locale
  # end

  # def default_url_options
  #   { locale: I18n.locale }
  # end
end
