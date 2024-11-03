class UsersController < ApplicationController
  layout 'index'

  before_action :authenticate_user!, except: [:index]

  def index
    @user = User.new
  end

  # def edit
  #   @user = current_user
  # end

  def update
    if current_user.update(user_params)
      redirect_to products_path, notice: 'Your account has been updated successfully.'
    else
      render :edit
    end
  end

  # private

  # def user_params
  #   params.require(:user).permit(:username, :email, :phone, :role, :password, :password_confirmation)
  # end
end










# class UsersController < ApplicationController
#   layout 'index'

#   before_action :set_user, only: [:edit, :update]
#   before_action :authenticate_user!, except: [ :index ]

#   def index
#     @user = User.new
#   end

#   def edit
#   end

#   def update
#     super do |resource|
#       if resource.errors.empty?
#         flash[:notice] = 'Your account has been updated successfully.'
#       end
#     end
#   end


#   private

#   def set_user
#     @user = current_user
#   end

#   def user_params
#     params.require(:user).permit(:username, :email, :phone, :role, :password, :password_confirmation)
#   end
# end
