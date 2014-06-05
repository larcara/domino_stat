class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user, :except => [:new, :destroy]

  def authenticate_user
    unless session[:user_name]
      redirect_to(:controller => 'session', :action => 'new')
      return false
    else
      # set current_user by the current user object
      @current_user = session[:user_name]
      return true
    end
  end
end
