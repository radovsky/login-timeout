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
  
  def should_lock_out?(user)
    user.failed_login_attempts >= 3 &&
    user.failed_login_time > 10.minutes.ago
  end
  
  def handle_problem_login
    user = User.find_by username: params[:user][:username]
    if user && should_lock_out?(user)
      mins = ((user.failed_login_time + 600 - Time.now)/60).to_i
      secs = ((user.failed_login_time + 600 - Time.now)%60).to_i
      flash[:errors] = [
        "You are locked out, #{
        user.username
        }. Try again in #{
        mins
        } minutes, #{
        secs
        } seconds"
      ]
    elsif user
      user.failed_login_attempts += 1
      user.failed_login_time = Time.now
      user.save
      flash[:errors] = [
        "Incorrect password. You will be locked out after #{
        3 - user.failed_login_attempts
        } more unsuccessful attempts"
        
      ]
    else
      flash[:errors] = [
        "Username and/or password is invalid"
      ]
    end
  end
end