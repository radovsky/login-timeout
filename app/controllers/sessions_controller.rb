class SessionsController < ApplicationController
  def create
    user = User.find_by_credentials(
      params[:user][:username],
      params[:user][:password]
    )
    if user
      sign_in!(user)
      redirect_to root_url
    else
      flash[:errors] = ["Username and/or password is invalid."]
      redirect_to new_user_url
    end
  end
  
  def destroy
    sign_out!
    redirect_to new_user_url
  end
end