class SessionsController < ApplicationController
  def create
    user = User.find_by_credentials(
      params[:user][:username],
      params[:user][:password]
    )
    if user
      user.failed_login_attempts = 0
      sign_in!(user)
      redirect_to root_url
    else
      user.failed_login_attempts += 1
      user.failed_login_time = Time.now
      flash[:errors] = ["Username and/or password is invalid."]
      redirect_to new_user_url
    end
  end
  
  def destroy
    sign_out!
    redirect_to new_user_url
  end
end