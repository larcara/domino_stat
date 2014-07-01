class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user, :except => [:new, :destroy]
  before_filter :menu_data, :except => [:new, :destroy]

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

  def menu_data
    @alerts=Notification.alerts.order(updated_at: :desc).limit(10)
    @messages=Notification.messages.order(updated_at: :desc).limit(10)
    @login_errors=Notification.login_errors.order(updated_at: :desc).limit(10)
    @domino_servers=DominoServer.enabled_for_tail.map{|x| [x.id, x.name]}


    @locks=DominoLock.where(["updated_at > ?", Date.today]).group(:database_name).count().sort_by { |a|  a[1]}.reverse[0,6]
  end
end
