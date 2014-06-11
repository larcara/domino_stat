class DominoMessagesController < ApplicationController
  before_action :set_domino_message, only: [:show, :edit, :update, :destroy]

  # GET /domino_messages
  # GET /domino_messages.json
  def index
    @domino_messages = DominoMessage.all
  end

  # GET /domino_messages/1
  # GET /domino_messages/1.json
  def show
  end

  # GET /domino_messages/new
  def new
    @domino_message = DominoMessage.new
  end

  # GET /domino_messages/1/edit
  def edit
  end

  # POST /domino_messages
  # POST /domino_messages.json
  def create
    @domino_message = DominoMessage.new(domino_message_params)

    respond_to do |format|
      if @domino_message.save
        format.html { redirect_to @domino_message, notice: 'Domino message was successfully created.' }
        format.json { render :show, status: :created, location: @domino_message }
      else
        format.html { render :new }
        format.json { render json: @domino_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domino_messages/1
  # PATCH/PUT /domino_messages/1.json
  def update
    respond_to do |format|
      if @domino_message.update(domino_message_params)
        format.html { redirect_to @domino_message, notice: 'Domino message was successfully updated.' }
        format.json { render :show, status: :ok, location: @domino_message }
      else
        format.html { render :edit }
        format.json { render json: @domino_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domino_messages/1
  # DELETE /domino_messages/1.json
  def destroy
    @domino_message.destroy
    respond_to do |format|
      format.html { redirect_to domino_messages_url, notice: 'Domino message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domino_message
      @domino_message = DominoMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def domino_message_params
      params.require(:domino_message).permit(:date, :time, :domino_server_id, :messageid, :notes_message_id, :mail_from, :mail_to, :size, :smtp_from, :mail_relay, :forward_by_rule, :message_type, :subject, :notes)
    end
end
