class NamesEntriesController < ApplicationController
  before_action :set_names_entry, only: [:show, :edit, :update, :destroy]

  # GET /names_entries
  # GET /names_entries.json
  def index
    @names_entries = NamesEntry.all
  end

  # GET /names_entries/1
  # GET /names_entries/1.json
  def show
  end

  # GET /names_entries/new
  def new
    @names_entry = NamesEntry.new
  end

  # GET /names_entries/1/edit
  def edit
  end

  # POST /names_entries
  # POST /names_entries.json
  def create
    @names_entry = NamesEntry.new(names_entry_params)

    respond_to do |format|
      if @names_entry.save
        format.html { redirect_to @names_entry, notice: 'Names entry was successfully created.' }
        format.json { render :show, status: :created, location: @names_entry }
      else
        format.html { render :new }
        format.json { render json: @names_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /names_entries/1
  # PATCH/PUT /names_entries/1.json
  def update
    respond_to do |format|
      if @names_entry.update(names_entry_params)
        format.html { redirect_to @names_entry, notice: 'Names entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @names_entry }
      else
        format.html { render :edit }
        format.json { render json: @names_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /names_entries/1
  # DELETE /names_entries/1.json
  def destroy
    @names_entry.destroy
    respond_to do |format|
      format.html { redirect_to names_entries_url, notice: 'Names entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_names_entry
      @names_entry = NamesEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def names_entry_params
      params.require(:names_entry).permit(:server_id, :cn, :lastname, :firstname, :mailserver, :email, :level0, :level1, :level2, :level3, :level4, :uid, :displayname, :status)
    end
end
