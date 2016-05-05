class CreateDeliverers < ActiveRecord::Migration
  def change
    create_table :deliverers do |t|
    	t.string  :plate_number
    end
  end
end
