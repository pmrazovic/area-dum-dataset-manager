class AddGeocodedToSections < ActiveRecord::Migration
  def change
  	add_column :sections, :geocoded, :boolean, :default => false
  end
end
