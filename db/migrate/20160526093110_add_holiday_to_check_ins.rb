class AddHolidayToCheckIns < ActiveRecord::Migration
  def change
  	add_column :check_ins, :is_holiday, :boolean, :default => false
  end
end
