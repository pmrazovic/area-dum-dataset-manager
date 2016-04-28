class AddIndex < ActiveRecord::Migration
  def change
  	add_index :check_ins, :section_id
  	add_index :check_ins, :deliverer_id
  	add_index :check_ins, :timestamp, :order => :desc
  	add_index :check_ins, [:deliverer_id, :timestamp], :order => :desc
  	add_index :check_ins, [:section_id, :timestamp], :order => :desc
  end
end
