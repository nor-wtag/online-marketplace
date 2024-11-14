class RegistrationsController < Devise::RegistrationsController
  before_action :set_resource, only: [ :edit, :update, :destroy, :delete, :update_profile ]
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout 'index'

  def delete
  end

  def update_profile
    @user = current_user
    return redirect_to homepage_path, alert: I18n.t('registrations.profile_update_failed', errors: 'User not found') unless @user


    if user_params[:password].blank? && user_params[:password_confirmation].blank?
      if @user.update(user_params.except(:password, :password_confirmation, :current_password))
        flash[:notice] = I18n.t('registrations.profile_updated')
        redirect_to homepage_path
      else
        flash[:alert] = I18n.t('registrations.profile_update_failed', errors: @user.errors.full_messages.to_sentence)
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.valid_password?(user_params[:current_password])
        if @user.update(user_params.except(:current_password))
          bypass_sign_in(@user)
          flash[:notice] = I18n.t('registrations.password_updated')
          redirect_to homepage_path
        else
          flash[:alert] = I18n.t('registrations.password_update_failed', errors: @user.errors.full_messages.to_sentence)
          render :edit, status: :unprocessable_entity
        end
      else
        flash[:alert] = I18n.t('registrations.current_password_incorrect')
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message!(:notice, I18n.t('registrations.account_deleted'))
    yield resource if block_given?
    respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
  end

  protected

  def set_resource
    self.resource = current_user
  end

  def user_params
    params.require(:user).permit(:username, :email, :phone, :password, :password_confirmation, :current_password)
  end

  def after_update_path_for(resource)
    homepage_path
  end
end
