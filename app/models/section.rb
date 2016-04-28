class Section < ActiveRecord::Base
	has_many :check_ins
	belongs_to :section_configuration
end
