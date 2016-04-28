class CreateCheckIns < ActiveRecord::Migration
  def change
    create_table :check_ins do |t|
    	t.integer  :deliverer_id
    	t.decimal  :latitude
    	t.decimal  :longitude
    	t.datetime :timestamp
    	t.integer  :section_id
    end
  end
end
