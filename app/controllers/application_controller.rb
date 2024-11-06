class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_users_path, alert: 'You need to sign in first.'
    end
  end
end
