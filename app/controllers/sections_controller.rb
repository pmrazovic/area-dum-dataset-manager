require 'csv'

class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :show_per_time_slot, :refresh_per_time_slot, :show_per_day_of_week, :refresh_per_day_of_week, :edit, :update, :destroy]

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
    @stats, @stats_weekend = get_per_time_slot_distibution(@min_datetime, @max_datetime, 30, false)
  end

  def refresh_per_time_slot
    time_slot_size = params[:time_slot_size].to_i
    @plot_type = params[:plot_type].to_i
    if !params[:start_datetime].blank? && !params[:end_datetime].blank?
      start_datetime = DateTime.strptime(params[:start_datetime], '%Y-%m-%d %H:%M')
      end_datetime = DateTime.strptime(params[:end_datetime], '%Y-%m-%d %H:%M')
      @stats, @stats_weekend = get_per_time_slot_distibution(start_datetime, end_datetime, time_slot_size, @plot_type)
    else
      @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
      @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
      @stats, @stats_weekend = get_per_time_slot_distibution(@min_datetime, @max_datetime, time_slot_size, @plot_type)
    end

  end

  def get_per_time_slot_distibution(start_datetime, end_datetime, time_slot_size, probability)
    check_in_count = CheckIn.where("section_id = ? AND 
                                    extract(dow from timestamp) IN (1,2,3,4,5) AND
                                    timestamp >= ? AND
                                    timestamp <= ?", @section.id, start_datetime, end_datetime).count
    check_in_count_weekend = CheckIn.where("section_id = ? AND 
                                            extract(dow from timestamp) IN (0, 6) AND
                                            timestamp >= ? AND
                                            timestamp <= ?", @section.id, start_datetime, end_datetime).count
    stats = ActiveSupport::OrderedHash.new
    stats_weekend = ActiveSupport::OrderedHash.new

    (0..23).each do |hour|
      (0..60/time_slot_size-1).each do |hour_slot|
        if hour_slot != 60/time_slot_size-1
          desc = "#{hour.to_s.rjust(2, "0")}:#{(time_slot_size*hour_slot).to_s.rjust(2, "0")}-#{hour.to_s.rjust(2, "0")}:#{(time_slot_size*(hour_slot+1)).to_s.rjust(2, "0")}"
        else
          desc = "#{hour.to_s.rjust(2, "0")}:#{(time_slot_size*hour_slot).to_s.rjust(2, "0")}-#{(hour+1).to_s.rjust(2, "0")}:00"
        end
        stats["#{hour}-#{hour_slot}"] = {:count => 0, :desc => desc}
        stats_weekend["#{hour}-#{hour_slot}"] = {:count => 0, :desc => desc}
      end
    end

    sql = "SELECT (extract(hour FROM timestamp)) AS hour,
                  (extract(minute FROM timestamp)::int / #{time_slot_size}) AS hour_slot,
                  count(*) AS total
           FROM check_ins
           WHERE section_id = #{@section.id} AND 
                 extract(dow from timestamp) IN (1,2,3,4,5) AND
                 timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d %H:%M")}', 'YYYY-MM-DD HH24:MI') AND
                 timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d %H:%M")}', 'YYYY-MM-DD HH24:MI')
           GROUP  BY 1, 2"

    ActiveRecord::Base.connection.execute(sql).each do |row|
      if probability == 1
        stats["#{row['hour']}-#{row['hour_slot']}"][:count] = row["total"].to_f/check_in_count.to_f
      else
        stats["#{row['hour']}-#{row['hour_slot']}"][:count] = row["total"].to_i
      end
    end

    sql = "SELECT (extract(hour FROM timestamp)) AS hour,
                  (extract(minute FROM timestamp)::int / #{time_slot_size}) AS hour_slot,
                  count(*) AS total
           FROM check_ins
           WHERE section_id = #{@section.id} AND extract(dow from timestamp) IN (0, 6) AND
                 timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d %H:%M")}', 'YYYY-MM-DD HH24:MI') AND
                 timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d %H:%M")}', 'YYYY-MM-DD HH24:MI')
           GROUP  BY 1, 2"

    ActiveRecord::Base.connection.execute(sql).each do |row|
      if probability == 1
        stats_weekend["#{row['hour']}-#{row['hour_slot']}"][:count] = row["total"].to_f/check_in_count_weekend.to_f
      else
        stats_weekend["#{row['hour']}-#{row['hour_slot']}"][:count] = row["total"].to_i
      end
    end

    return [stats, stats_weekend]
  end

  def show_per_day_of_week
    @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
    @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
    @stats = get_per_day_of_week_distibution(@min_datetime, @max_datetime, false)
  end

  def refresh_per_day_of_week
    @plot_type = params[:plot_type].to_i
    if !params[:start_datetime].blank? && !params[:end_datetime].blank?
      start_datetime = DateTime.strptime(params[:start_datetime], '%Y-%m-%d %H:%M')
      end_datetime = DateTime.strptime(params[:end_datetime], '%Y-%m-%d %H:%M')
      @stats = get_per_day_of_week_distibution(start_datetime, end_datetime, @plot_type)
    else
      @max_datetime = CheckIn.where(:section_id => @section.id).maximum(:timestamp)
      @min_datetime = CheckIn.where(:section_id => @section.id).minimum(:timestamp)
      @stats = get_per_day_of_week_distibution(@min_datetime, @max_datetime, @plot_type)
    end
  end

  def get_per_day_of_week_distibution(start_datetime, end_datetime, probability)
    check_in_count = CheckIn.where("section_id = ? AND 
                                    timestamp >= ? AND
                                    timestamp <= ?", @section.id, start_datetime, end_datetime).count

    stats = ActiveSupport::OrderedHash.new
    stats["0"] = {:count => 0, :desc => "Sunday"}
    stats["1"] = {:count => 0, :desc => "Monday"}
    stats["2"] = {:count => 0, :desc => "Tuesday"}
    stats["3"] = {:count => 0, :desc => "Wednesday"}
    stats["4"] = {:count => 0, :desc => "Thursday"}
    stats["5"] = {:count => 0, :desc => "Friday"}
    stats["6"] = {:count => 0, :desc => "Saturday"}

    sql = "SELECT extract(dow from timestamp) AS day_of_week,
                  count(*) AS total
           FROM check_ins
           WHERE section_id = #{@section.id} AND
                 timestamp >= TO_TIMESTAMP('#{start_datetime.strftime("%Y-%m-%d %H:%M")}', 'YYYY-MM-DD HH24:MI') AND
                 timestamp <= TO_TIMESTAMP('#{end_datetime.strftime("%Y-%m-%d %H:%M")}', 'YYYY-MM-DD HH24:MI')
           GROUP  BY day_of_week"

    ActiveRecord::Base.connection.execute(sql).each do |row|
      if probability == 1
        stats[row['day_of_week']][:count] = row["total"].to_f/check_in_count.to_f
      else
        stats[row['day_of_week']][:count] = row["total"].to_i
      end
    end

    return stats

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
                                :district_id => row[11].to_i,
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
