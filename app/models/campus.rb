class Campus < ActiveRecord::Base
  attr_accessible :name

  has_many :cohorts
  has_many :campus_administrators
  has_many :administrators, through: :capus_administrators, order: :name

  validates :name, uniqueness: true

end
