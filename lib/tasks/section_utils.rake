require 'csv'
require 'geoutm'
require 'open-uri'
require 'cgi'
require 'json'
require 'open-uri'

namespace :section_utils do
  desc "Reads CSV file and updates section coordinates"
  task update_coordinates_from_csv: :environment do
  	CSV.foreach(File.join(Rails.root, "db", "seed_data", "section_coordinates.csv"), :headers => true, :encoding => 'UTF-8') do |row|
    	section = Section.where(:id => row["ID_TRAMO"].to_i).first
    	utm_ix = row["UTM_IX_OK"].to_f
    	utm_iy = row["UTM_IY_OK"].to_f
    	utm_fx = row["UTM_FX_OK"].to_f
    	utm_fy = row["UTM_FY_OK"].to_f

    	ll_i = GeoUtm::UTM.new("31T", utm_ix, utm_iy).to_lat_lon
    	ll_f = GeoUtm::UTM.new("31T", utm_fx, utm_fy).to_lat_lon

    	lat = (ll_i.lat + ll_f.lat)/2.0
    	lon = (ll_i.lon + ll_f.lon)/2.0

    	unless section.nil?
    		section.latitude = lat
    		section.longitude = lon
    		section.save
    	end
  	end
  end

  desc "Calls Google geocode service and updates section coordinates"
  task update_coordinates_with_google_geocode: :environment do
  	sections_to_geocode = Section.where("latitude = 0.0 OR longitude = 0.0 OR geocoded = TRUE")

  	sections_to_geocode.each do |section|
  		query_address = section.street.official_name.split(" ").join("+") + "+" + section.street_no.to_s + "+Barcelona"
  		api_url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false"
  		api_query = "#{api_url}&address=#{URI::encode(query_address)}"
  		puts api_query
  		 open(api_query) do |response|
      	if response.status[0] == "200"		
      		r = JSON.parse(response.read)
      		lat = r["results"][0]["geometry"]["location"]["lat"].to_f
      		lon = r["results"][0]["geometry"]["location"]["lng"].to_f
      		section.latitude = lat
      		section.longitude = lon
      		section.geocoded = true
      		section.save
      	end
    	end
  	end

  end

  desc "Computes occupancy percentage of each depot"
  task compute_occupancy: :environment do
    dt = 5.minutes
    duration = 10.minutes

    start_datetime = Time.at((CheckIn.minimum("timestamp").to_f / dt).floor * dt).utc
    end_datetime = Time.at((CheckIn.maximum("timestamp").to_f / dt).ceil * dt).utc
    
    time_series = Hash.new

    counter = 0
    total = Section.all.count
    Section.all.order("id").each do |section|
      counter += 1
      print "\r#{(((counter).to_f/total)*100).round(2)}% complete"
      current_time_slot = start_datetime
      time_series[section] = Hash.new { |hash, key| hash[key] = 0 }
      CheckIn.where("section_id = ?", section.id).all.each do |check_in|
        start_time_slot = Time.at((check_in.timestamp.to_f / dt).ceil * dt).utc
        curr_time_slot = start_time_slot
        while curr_time_slot < start_time_slot + duration
          if time_series[section][curr_time_slot] < section.authorized_spaces
            time_series[section][curr_time_slot] += 1
          end
          curr_time_slot += dt
        end
      end
    end

    file = File.open("section_occupancies.csv", "w")
    puts "\nPrinting result in output file..."
    file.puts "depot_id,timestamp,occupancy,occupancy_norm"

    counter = 0
    Section.all.order("id").each do |section|
      counter += 1
      print "\r#{(((counter).to_f/total)*100).round(2)}% complete"
      time_series[section].each do |time_slot, occupancy|
        file.puts "#{section.id},#{time_slot.strftime("%Y-%m-%d %H:%M")},#{occupancy},#{occupancy.to_f/section.authorized_spaces}"
      end
    end

    file.close

  end


end