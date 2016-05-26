namespace :check_ins_utils do
  desc "Reads OpenData XML file and updates section coordinates"
  task mark_holidays: :environment do
  	holiday_check_ins = CheckIn.where("date(timestamp) in (?)",['2016-01-01', '2016-01-06'])
  	holiday_check_ins.each do |check_in|
  		check_in.is_holiday = true
  	end
  end
end