class CreateSectionConfigurations < ActiveRecord::Migration
  def change
    create_table :section_configurations do |t|
    	t.integer :tariff_id
    	t.integer :schedule_id
    	t.integer :configuration_type_id
    	t.string  :color_desc
    	t.string  :color_desc_pda
    	t.string  :configuration_code
    	t.boolean :active
    	t.string  :tariff_code
    	t.string  :schedule_code
    	t.string  :configuration_type_code
    	t.string  :description
    	t.string  :tarrif_description_short
    	t.string  :schedule_description_short
    	t.boolean :include_holidays
    	t.boolean :only_parking
    	t.integer :fraction_type
    	t.integer :fraction_price
    	t.decimal :max_time
    	t.decimal :price_per_hour
    	t.decimal :price_per_minute
    	t.decimal :price_per_second
    end
  end
end
