require 'csv'

class SectionConfigurationsController < ApplicationController
  before_action :set_section_configuration, only: [:show, :edit, :update, :destroy]

  # GET /section_configurations
  # GET /section_configurations.json
  def index
    @section_configurations = SectionConfiguration.all.sort
  end

  # GET /section_configurations/1
  # GET /section_configurations/1.json
  def show
  end

  # GET /section_configurations/new
  def new
    @section_configuration = SectionConfiguration.new
  end

  # GET /section_configurations/1/edit
  def edit
  end

  # POST /section_configurations
  # POST /section_configurations.json
  def create
    @section_configuration = SectionConfiguration.new(section_configuration_params)

    respond_to do |format|
      if @section_configuration.save
        format.html { redirect_to @section_configuration, notice: 'Section configuration was successfully created.' }
        format.json { render :show, status: :created, location: @section_configuration }
      else
        format.html { render :new }
        format.json { render json: @section_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /section_configurations/1
  # PATCH/PUT /section_configurations/1.json
  def update
    respond_to do |format|
      if @section_configuration.update(section_configuration_params)
        format.html { redirect_to @section_configuration, notice: 'Section configuration was successfully updated.' }
        format.json { render :show, status: :ok, location: @section_configuration }
      else
        format.html { render :edit }
        format.json { render json: @section_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /section_configurations/1
  # DELETE /section_configurations/1.json
  def destroy
    @section_configuration.destroy
    respond_to do |format|
      format.html { redirect_to section_configurations_url, notice: 'Section configuration was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import_csv
  end

  def process_csv
    uploaded_file = params[:configurations_csv]
    batch,batch_size = [], 1_000 
    CSV.foreach(uploaded_file.path, headers: true, encoding:'iso-8859-1:utf-8') do |row|
      new_configuration = SectionConfiguration.new(:tariff_id => row[1].to_i,
                                                   :schedule_id => row[2].to_i,
                                                   :configuration_type_id => row[3].to_i,
                                                   :color_desc => row[4].to_s,
                                                   :color_desc_pda => row[5].to_s,
                                                   :configuration_code => row[6].to_s,
                                                   :active => row[7].to_i == 1 ? true : false,
                                                   :tariff_code => row[8].to_s,
                                                   :schedule_code => row[9].to_s,
                                                   :configuration_type_code => row[10].to_s,
                                                   :description => row[11].to_s,
                                                   :tarrif_description_short => row[12].to_s,
                                                   :schedule_description_short => row[13].to_s,
                                                   :include_holidays => row[14].to_i == 1 ? true : false,
                                                   :only_parking => row[15].to_i == 1 ? true : false,
                                                   :fraction_type => row[16].to_i,
                                                   :fraction_price => row[17].to_i,
                                                   :max_time => row[18].to_f,
                                                   :price_per_hour => row[19].to_f,
                                                   :price_per_minute => row[20].to_f,
                                                   :price_per_second => row[21].to_f)
      new_configuration.id = row[0].to_i
      batch << new_configuration

      if batch.size >= batch_size
        SectionConfiguration.import batch
        batch = []
      end
    end
    SectionConfiguration.import batch

    redirect_to :action => :index
  end

  def delete_all
  end

  def confirm_delete_all
    SectionConfiguration.delete_all
    redirect_to :action => :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section_configuration
      @section_configuration = SectionConfiguration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_configuration_params
      params.fetch(:section_configuration, {})
    end
end
