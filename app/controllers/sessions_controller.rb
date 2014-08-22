class SessionsController < ApplicationController
  def create
    user = User.find_by_credentials(
      params[:user][:username],
      params[:user][:password]
    )
    if user && !should_lock_out?(user)
      user.failed_login_attempts = 0
      sign_in!(user)
      redirect_to root_url
    else
      #parameters: failed_login_mins, lockout_mins
      handle_problem_login(5, 10)
      redirect_to new_session_url
    end
  end
  
  def destroy
    sign_out!
    redirect_to new_user_url
  end
end