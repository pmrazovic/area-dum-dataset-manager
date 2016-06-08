class CheckIn < ActiveRecord::Base
	belongs_to :section
	belongs_to :deliverer
end
