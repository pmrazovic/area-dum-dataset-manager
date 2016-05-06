class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
    	t.string :name
    end
  end
end
