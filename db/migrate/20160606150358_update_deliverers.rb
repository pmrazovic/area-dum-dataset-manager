class UpdateDeliverers < ActiveRecord::Migration
  def change
  	add_column :deliverers, :fleet_id, :integer
  	add_index :deliverers, :plate_number, :unique => true
  	add_index :deliverers, :fleet_id
  end
end
