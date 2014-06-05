# encoding: utf-8
class SessionController < ApplicationController
  before_filter :authenticate_user, :except => [:new, :create]
  def new
    dd=DominoServer.all
    @servers=dd.map do |x|
      [x.name, x.id]
    end
    render layout: "login"
  end

  def create
    server=DominoServer.find(params[:server])

    session[:user_name]=nil
    ldap=Net::LDAP.new(host: server.ip, port: server.ldap_port,
                       auth: {:method=>:simple, username: params[:username_or_email], password: params[:login_password]})
    ldap.encryption(:simple_tls) if server.ldap_port!="389"

    begin
      if ldap.bind
       session[:user_name]=params[:username_or_email]
       redirect_to root_path, notice: 'UserName ok'
      else
        redirect_to root_path, notice: 'Invalid Credential.'
      end
    rescue Net::LDAP::LdapError
     redirect_to root_path, notice: 'Invalid Credential.'
    rescue
     redirect_to root_path, notice: 'generic error'
    end

  end

  def destroy
    session[:user_name]=nil
    redirect_to root_path
  end
end
