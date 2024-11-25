class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  require 'cancan'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: I18n.t('errors.access_denied')
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to new_user_session_path, alert: I18n.t('errors.access_denied')
  end

  def after_sign_in_path_for(resource)
    homepage_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_up_path_for(resource)
    homepage_path
  end

  def after_update_path_for(resource)
    homepage_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :phone, :role, :password, :password_confirmation ])
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
