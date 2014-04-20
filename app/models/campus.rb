class Campus < ActiveRecord::Base
  attr_accessible :name

  has_many :cohorts

  validates :name, uniqueness: true

end
