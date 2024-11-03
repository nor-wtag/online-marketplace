# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(resource)
    products_path
  end

  def update_resource(resource, params)
    if params[:current_password].present?
      super
    else

      params.delete(:password)
      params.delete(:password_confirmation)
      resource.update_without_password(params)
    end
  end

end






# class RegistrationsController < Devise::RegistrationsController
#   def after_sign_up_path_for(resource)
#     products_path
#   end

#   def after_inactive_sign_up_path_for(resource)
#     products_path
#   end

#   def after_update_path_for(resource)
#     products_path
#   end

#   def after_sign_out_path_for(resource_or_scope)
#     root_path
#   end
# end






# class RegistrationsController < Devise::RegistrationsController
#   # Redirect paths after actions
#   def after_sign_up_path_for(resource)
#     products_path
#   end

#   def after_inactive_sign_up_path_for(resource)
#     products_path
#   end

#   def after_update_path_for(resource)
#     products_path
#   end

#   def after_sign_out_path_for(resource_or_scope)
#     root_path
#   end

#   protected

#   def configure_permitted_parameters
#     devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :phone, :role])
#     devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :phone, :role, :password, :password_confirmation, :current_password])
#   end
# end
