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
    list_of_duplicates = []

    uploaded_file = params[:checkins_csv]
    check_in_batch,batch_size = [], 1_000 
    CSV.foreach(uploaded_file.path, {:headers => true, :col_sep => ",", :encoding => "iso-8859-1:utf-8"}) do |row|

      new_check_in = CheckIn.new(:latitude => row["START_LATITUD"].to_f,
                                 :longitude => row["START_LONGITUD"].to_f,
                                 :timestamp => DateTime.strptime(row["FHSTARTREAL"], '%Y-%m-%d %H:%M:%S'),
                                 :section_id => row["ID_TRAMO"].to_i)

      #

      #new_deliverer = Deliverer.where(:plate_number => row["COD_MATR"].to_s).first
      #if new_deliverer.nil?
      #  new_deliverer = Deliverer.new(:plate_number => row["COD_MATR"].to_s, :fleet_id => row["ID_USUARIO"].to_i)
      #  new_deliverer.save!
      #else
      #  if new_deliverer.fleet_id != row["ID_USUARIO"].to_i
      #    list_of_duplicates << new_deliverer.plate_number
      #  end
      #end

      #new_check_in.deliverer = new_deliverer
      
      check_in_batch << new_check_in

      if check_in_batch.size >= batch_size
        CheckIn.import check_in_batch
        check_in_batch = []
      end

    end
    CheckIn.import check_in_batch

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
    start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
    end_date = Date.strptime(params[:end_date], '%Y-%m-%d')

    if params[:deliverer_id].blank?
      @check_ins = CheckIn.where("timestamp > ? and timestamp < ?", start_date, end_date)
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
