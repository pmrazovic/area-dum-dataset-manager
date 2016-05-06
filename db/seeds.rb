require "csv"

puts "Creating admin user..."

User.find_or_create_by(:email => 'admin@areadum.com') do |account|
  account.password = 'password'
end

puts "Admin user created!"

ActiveRecord::Base.transaction do

	puts "Importing streets..."
  CSV.foreach(File.join(Rails.root, "db", "seed_data", "streets_opendata.csv"), :headers => true, :encoding => 'UTF-8') do |row|
    row = row.to_hash
    Street.find_or_create_by(:id => row["STREET_ID"]) do |street|
			street.official_name = row["OFFICIAL_NAME"]
			street.short_name = row["SHORT_NAME"]
		end
  end
  puts "Streets imported!"

	puts "Importing districts..."
  CSV.foreach(File.join(Rails.root, "db", "seed_data", "districts_opendata.csv"), :headers => true, :encoding => 'UTF-8') do |row|
    row = row.to_hash
    District.find_or_create_by(:id => row["DISTRICT_ID"]) do |district|
			district.name = row["NAME"]
		end
  end
  puts "Districts imported!"

  puts "Importing neighbourhoods..."
  CSV.foreach(File.join(Rails.root, "db", "seed_data", "neighbourhoods_opendata.csv"), :headers => true, :encoding => 'UTF-8') do |row|
    row = row.to_hash
    Neighbourhood.find_or_create_by(:id => row["NEIGHBOURHOOD_ID"]) do |neighbourhood|
			neighbourhood.name = row["NAME"]
			neighbourhood.district_id = row["DISTRICT_ID"]
		end
  end
  puts "Neighbourhoods imported!"
  
end