class UsersController < ApplicationController
  def new;end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.failed_login_attempts = 0
      sign_in!(@user)
      redirect_to root_url
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to new_user_url
    end
  end  

  private
  def user_params
    params.require(:user).permit(:username, :password)
  end
end