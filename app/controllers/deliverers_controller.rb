class DeliverersController < ApplicationController
  before_action :set_deliverer, only: [:show, :edit, :update, :destroy, :refresh_map_view]

  # GET /deliverers
  # GET /deliverers.json
  def index
    @deliverers = Deliverer.all.order(:id).paginate(:page => params[:page], :per_page => 100)
  end

  # GET /deliverers/1
  # GET /deliverers/1.json
  def show
  end

  # GET /deliverers/new
  def new
    @deliverer = Deliverer.new
  end

  # GET /deliverers/1/edit
  def edit
  end

  # POST /deliverers
  # POST /deliverers.json
  def create
    @deliverer = Deliverer.new(deliverer_params)

    respond_to do |format|
      if @deliverer.save
        format.html { redirect_to @deliverer, notice: 'Deliverer was successfully created.' }
        format.json { render :show, status: :created, location: @deliverer }
      else
        format.html { render :new }
        format.json { render json: @deliverer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliverers/1
  # PATCH/PUT /deliverers/1.json
  def update
    respond_to do |format|
      if @deliverer.update(deliverer_params)
        format.html { redirect_to @deliverer, notice: 'Deliverer was successfully updated.' }
        format.json { render :show, status: :ok, location: @deliverer }
      else
        format.html { render :edit }
        format.json { render json: @deliverer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliverers/1
  # DELETE /deliverers/1.json
  def destroy
    @deliverer.destroy
    respond_to do |format|
      format.html { redirect_to deliverers_url, notice: 'Deliverer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def refresh_map_view
    if (params[:start_date].blank? || params[:end_date].blank?)
      @check_ins = []
    else
      start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
      end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
      @check_ins = CheckIn.where("deliverer_id = ? AND timestamp > ? AND timestamp < ?", @deliverer.id, start_date, end_date)
    end

    puts @check_ins.count.inspect
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deliverer
      @deliverer = Deliverer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def deliverer_params
      params.fetch(:deliverer, {})
    end
end
