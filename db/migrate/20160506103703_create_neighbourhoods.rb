class CreateNeighbourhoods < ActiveRecord::Migration
  def change
    create_table :neighbourhoods do |t|
    	t.string :name
    	t.integer :district_id
    end
  end
end
