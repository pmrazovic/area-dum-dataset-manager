require 'csv'
require 'statistic_queries'

class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :show_per_time_slot, :refresh_per_time_slot, :show_per_day_of_week, 
                                     :refresh_per_day_of_week, :show_avg_per_time_slot, :refresh_avg_per_time_slot, 
                                     :show_avg_per_day_of_week, :refresh_avg_per_day_of_week, :download_csv_reports,
                                     :edit, :update, :destroy]

  # GET /sections
  # GET /sections.json
  def index
    @sections = Section.all.paginate(:page => params[:page], :per_page => 100)
  end

  # GET /sections/1
  # GET /sections/1.json
  def show
  end

  def show_per_time_slot
    @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
    @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
    @stats = StatisticQueries::Sections::total_check_ins_per_time_slot(@section, @min_datetime, @max_datetime, 30, [1,2,3,4,5]).to_a
  end

  def refresh_per_time_slot
    time_slot_size = params[:time_slot_size].to_i
    days_of_week = params[:day_of_week].split(",").map(&:to_i)
    @plot_type = params[:plot_type].to_i
    if !params[:start_date].blank? && !params[:end_date].blank?
      start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
      end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
      @stats = StatisticQueries::Sections::total_check_ins_per_time_slot(@section, start_date, end_date, time_slot_size, days_of_week).to_a
    else
      @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
      @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
      @stats = StatisticQueries::Sections::total_check_ins_per_time_slot(@section, @min_datetime, @max_datetime, time_slot_size, days_of_week).to_a
    end

  end

  def show_per_day_of_week
    @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
    @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
    @stats = StatisticQueries::Sections::total_check_ins_per_day_of_week(@section, @min_datetime, @max_datetime).to_a
  end

  def refresh_per_day_of_week
    @plot_type = params[:plot_type].to_i
    if !params[:start_date].blank? && !params[:end_date].blank?
      start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
      end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
      @stats = StatisticQueries::Sections::total_check_ins_per_day_of_week(@section, start_date, end_date).to_a
    else
      @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
      @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
      @stats = StatisticQueries::Sections::total_check_ins_per_day_of_week(@section, @min_datetime, @max_datetime).to_a
    end
  end

  def show_avg_per_time_slot
    @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
    @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
    @stats = StatisticQueries::Sections::avg_check_ins_per_time_slot(@section, @min_datetime, @max_datetime, 30, [1,2,3,4,5]).to_a
  end

  def refresh_avg_per_time_slot
    days_of_week = params[:day_of_week].split(",").map(&:to_i)
    time_slot_size = params[:time_slot_size].to_i
    if !params[:start_date].blank? && !params[:end_date].blank?
      start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
      end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
      @stats = StatisticQueries::Sections::avg_check_ins_per_time_slot(@section, start_date, end_date, time_slot_size, days_of_week).to_a
    else
      @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
      @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
      @stats = StatisticQueries::Sections::avg_check_ins_per_time_slot(@section, @min_datetime, @max_datetime, time_slot_size, days_of_week).to_a
    end
  end

  def show_avg_per_day_of_week
    @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
    @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
    @stats = StatisticQueries::Sections::avg_check_ins_per_day_of_week(@section, @min_datetime, @max_datetime).to_a
  end

  def refresh_avg_per_day_of_week
    if !params[:start_date].blank? && !params[:end_date].blank?
      start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
      end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
      @stats = StatisticQueries::Sections::avg_check_ins_per_day_of_week(@section, start_date, end_date).to_a
    else
      @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
      @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
      @stats = StatisticQueries::Sections::avg_check_ins_per_day_of_week(@section, @min_datetime, @max_datetime).to_a
    end
  end

  def download_csv_reports
  end

  # GET /sections/new
  def new
    @section = Section.new
  end

  # GET /sections/1/edit
  def edit
  end

  # POST /sections
  # POST /sections.json
  def create
    @section = Section.new(section_params)

    respond_to do |format|
      if @section.save
        format.html { redirect_to @section, notice: 'Section was successfully created.' }
        format.json { render :show, status: :created, location: @section }
      else
        format.html { render :new }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sections/1
  # PATCH/PUT /sections/1.json
  def update
    respond_to do |format|
      if @section.update(section_params)
        format.html { redirect_to @section, notice: 'Section was successfully updated.' }
        format.json { render :show, status: :ok, location: @section }
      else
        format.html { render :edit }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.json
  def destroy
    @section.destroy
    respond_to do |format|
      format.html { redirect_to sections_url, notice: 'Section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import_csv
  end

  def process_csv
    uploaded_file = params[:sections_csv]
    batch,batch_size = [], 1_000 
    CSV.foreach(uploaded_file.path, headers: true, encoding:'iso-8859-1:utf-8') do |row|

      new_section = Section.new(:latitude => 0.0,
                                :longitude => 0.0,
                                :dum_zone_id => row[2].to_i,
                                :section_name => row[3],
                                :street_id => row[4].to_i,
                                :street_no => row[5].to_i,
                                :section_type_id => row[6].to_i,
                                :authorized_spaces => row[7].to_i,
                                :unavailable_spaces => row[8].to_i,
                                :available_spaces => row[9].to_i,
                                :section_configuration_id => row[10].to_i,
                                # District IDs not mach open data uless
                                :district_id => row[11].to_i - 1,
                                :neighbourhood_id => row[12].to_i,
                                :regulatory_zone_id => row[13].to_i)

      if row[0] == "30-4-2015 00:00:00"
        new_section.id = row[1].to_i
        batch << new_section
      end

      if batch.size >= batch_size
        Section.import batch
        batch = []
      end
    end
    Section.import batch

    redirect_to :action => :index
  end

  def delete_all
  end

  def confirm_delete_all
    Section.delete_all
    redirect_to :action => :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.fetch(:section, {})
    end
end
