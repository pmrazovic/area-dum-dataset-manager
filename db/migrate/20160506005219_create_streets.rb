class CreateStreets < ActiveRecord::Migration
  def change
    create_table :streets do |t|
    	t.string :street_type
    	t.string :official_name
    	t.string :short_name
    end
  end
end
