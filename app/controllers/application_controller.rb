class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?
  
  private
  def current_user
    @current_user ||= User
      .find_by_session_token(
        session[:session_token]
      )
  end
  
  def signed_in?
    !!current_user
  end
    
  def sign_in!(user)
    @current_user = user
    session[:session_token] = user.reset_token!
  end
  
  def sign_out!
    current_user.try(:reset_token!)
    session[:session_token] = nil
  end
  
  def require_signed_in!
    redirect_to new_user_url unless signed_in?
  end
  
  def should_lock_out?(user, lockout_mins=10)
    user.failed_login_attempts > 2 &&
    user.failed_login_time > lockout_mins.minutes.ago
  end
  
  def failed_attempt(user, failed_login_mins=5, lockout_mins=10)
    user.failed_login_attempts += 1
    if user.failed_login_attempts == 1
      user.failed_login_time = Time.now
    elsif user.failed_login_attempts >= 3
      if user.failed_login_time > failed_login_mins.minutes.ago
        user.lockout_time = Time.now
      else
        user.failed_login_attempts = 1
        user.failed_login_time = Time.now
      end
    end
    user.save
    set_failed_attempt_errors(user, lockout_mins)
  end
  
  def set_failed_attempt_errors(user, lockout_mins)
    remaining = 3 - user.failed_login_attempts
    if remaining == 0
      flash[:errors] = [
        "You are locked out, #{user.username}",
        "Try again in #{lockout_mins} minutes"
      ]
    else
      flash[:errors] = [
        "Incorrect password",
        "You will be locked out after #{remaining} more unsuccessful attempts"
      ]
    end
  end
  
  def handle_problem_login(failed_login_mins=5, lockout_mins=10)
    user = User.find_by username: params[:user][:username]
    if user && should_lock_out?(user, lockout_mins)
      mins = ((user.lockout_time + lockout_mins * 60 - Time.now) / 60).to_i
      secs = ((user.lockout_time + lockout_mins * 60 - Time.now) % 60).to_i
      flash[:errors] = [
        "You are locked out, #{user.username}",
        "Try again in #{mins} minutes, #{secs} seconds"
      ]
    elsif user
      failed_attempt(user, failed_login_mins, lockout_mins)
    else
      flash[:errors] = [
        "Username and/or password is invalid"
      ]
    end
  end
end