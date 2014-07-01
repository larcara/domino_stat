class DominoServersController < ApplicationController
  before_action :set_domino_server, only: [:show, :edit, :update, :destroy]

  # GET /domino_servers
  # GET /domino_servers.json
  def index
    @domino_servers = DominoServer.all
  end

  # GET /domino_servers/1
  # GET /domino_servers/1.json
  def show
  end

  # GET /domino_servers/new
  def new
    @domino_server = DominoServer.new
  end

  # GET /domino_servers/1/edit
  def edit
  end

  # POST /domino_servers
  # POST /domino_servers.json
  def create
    @domino_server = DominoServer.new(domino_server_params)

    respond_to do |format|
      if @domino_server.save
        format.html { redirect_to @domino_server, notice: 'Domino server was successfully created.' }
        format.json { render :show, status: :created, location: @domino_server }
      else
        format.html { render :new }
        format.json { render json: @domino_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domino_servers/1
  # PATCH/PUT /domino_servers/1.json
  def update
    respond_to do |format|
      if @domino_server.update(domino_server_params)
        format.html { redirect_to @domino_server, notice: 'Domino server was successfully updated.' }
        format.json { render :show, status: :ok, location: @domino_server }
      else
        format.html { render :edit }
        format.json { render json: @domino_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domino_servers/1
  # DELETE /domino_servers/1.json
  def destroy
    @domino_server.destroy
    respond_to do |format|
      format.html { redirect_to domino_servers_url, notice: 'Domino server was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /domino_servers
  # POST /domino_servers.json
  def load_names_entry
    set_domino_server
    @domino_server.import_contact_from_ldap
    respond_to do |format|
      format.html { redirect_to domino_servers_url, notice: 'Names Entry imported.' }
      format.json { head :no_content }
    end
  end

  # POST /domino_servers
  # POST /domino_servers.json
  def tail

    set_domino_server
    flag=@domino_server.tail_status
    flag.blank? ? DominoLog.new(@domino_server.id).do_tail : @domino_server.update_attribute(:tail_status, "")
    message = flag.blank? ? "Started Tail" : "Stopped Tail"

        respond_to do |format|
      format.html { redirect_to domino_servers_url, notice: message }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domino_server
      @domino_server = DominoServer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def domino_server_params
      result=params.require(:domino_server).permit(:name, :ip, :ldap_treebase, :ldap_hostname, :ldap_port, :ldap_auth_method, :ldap_filter, :ldap_username, :ldap_pwd, :ssh_user, :ssh_pwd)
      #[:ssh_password,:ldap_password].each {|x| result.delete(x) if result[x].blank?}
      result
    end
end
