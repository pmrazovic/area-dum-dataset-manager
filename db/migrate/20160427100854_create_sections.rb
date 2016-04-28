class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
    	t.decimal :latitude
    	t.decimal :longitude
    	t.integer :dum_zone_id
        t.string  :section_name
    	t.integer :street_id
    	t.integer :street_no
    	t.integer :section_type_id
        t.integer :authorized_spaces
        t.integer :unavailable_spaces
        t.integer :available_spaces
    	t.integer :section_configuration_id
    	t.integer :district_id
    	t.integer :neighbourhood_id
    	t.integer :regulatory_zone_id
    end
  end
end
