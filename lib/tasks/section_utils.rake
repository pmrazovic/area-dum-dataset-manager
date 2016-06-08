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



end
