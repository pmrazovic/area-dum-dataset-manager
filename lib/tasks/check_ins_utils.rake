namespace :check_ins_utils do
  desc "Reads OpenData XML file and updates section coordinates"
  task mark_holidays: :environment do
  	holiday_check_ins = CheckIn.where("date(timestamp) in (?)", ['2016-01-01', 
  																														   '2016-01-06',
  																														   '2016-02-12',
  																														   '2016-03-25',
  																														   '2016-03-28',
  																														   '2016-05-16',
  																														   '2016-06-23',
  																														   '2016-06-24',
  																														   '2016-08-15',
  																														   '2016-09-11',
  																														   '2016-09-24',
  																														   '2016-10-12',
  																														   '2016-12-06',
  																														   '2016-12-08',
  																														   '2016-12-25',
  																														   '2016-12-26'])
  	holiday_check_ins.each do |check_in|
  		check_in.is_holiday = true
  		check_in.save
  	end
  end
end