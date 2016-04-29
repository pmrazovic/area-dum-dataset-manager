require 'csv'

class CheckInsController < ApplicationController
  before_action :set_check_in, only: [:show, :edit, :update, :destroy]

  # GET /check_ins
  # GET /check_ins.json
  def index
    @check_ins = CheckIn.all.paginate(:page => params[:page], :per_page => 100)
  end

  # GET /check_ins/1
  # GET /check_ins/1.json
  def show
  end

  # GET /check_ins/new
  def new
    @check_in = CheckIn.new
  end

  # GET /check_ins/1/edit
  def edit
  end

  # POST /check_ins
  # POST /check_ins.json
  def create
    @check_in = CheckIn.new(check_in_params)

    respond_to do |format|
      if @check_in.save
        format.html { redirect_to @check_in, notice: 'Check in was successfully created.' }
        format.json { render :show, status: :created, location: @check_in }
      else
        format.html { render :new }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_ins/1
  # PATCH/PUT /check_ins/1.json
  def update
    respond_to do |format|
      if @check_in.update(check_in_params)
        format.html { redirect_to @check_in, notice: 'Check in was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_in }
      else
        format.html { render :edit }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_ins/1
  # DELETE /check_ins/1.json
  def destroy
    @check_in.destroy
    respond_to do |format|
      format.html { redirect_to check_ins_url, notice: 'Check in was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

    def import_csv
  end

  def process_csv
    uploaded_file = params[:checkins_csv]
    batch,batch_size = [], 1_000 
    CSV.foreach(uploaded_file.path, headers: true) do |row|
      new_check_in = CheckIn.new(:latitude => row[4].to_f,
                                 :longitude => row[5].to_f,
                                 :timestamp => DateTime.strptime(row[6], '%d-%m-%Y %H:%M:%S'),
                                 :section_id => row[18].to_i)
      batch << new_check_in

      if batch.size >= batch_size
        CheckIn.import batch
        batch = []
      end
    end
    CheckIn.import batch

    redirect_to :action => :index
  end

  def delete_all
  end

  def confirm_delete_all
    CheckIn.delete_all
    redirect_to :action => :index
  end

  def show_on_map
  end

  def refresh_map_view
    start_datetime = DateTime.strptime(params[:start_datetime], '%Y-%m-%d %H:%M')
    end_datetime = DateTime.strptime(params[:end_datetime], '%Y-%m-%d %H:%M')

    if params[:deliverer_id].blank?
      @check_ins = CheckIn.where("timestamp > ? and timestamp < ?", start_datetime, end_datetime)
    else
      deliverer_id = params[:deliverer_id].to_i
      @check_ins = []
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check_in
      @check_in = CheckIn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_in_params
      params.fetch(:check_in, {})
    end
end
