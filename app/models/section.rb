class Section < ActiveRecord::Base
	has_many :check_ins
	belongs_to :section_configuration
	belongs_to :street
	belongs_to :district
	belongs_to :neighbourhood
end
