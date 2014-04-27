class Campus < ActiveRecord::Base
  attr_accessible :name, :administrator_ids

  has_many :cohorts
  has_many :campus_administrators
  has_many :administrators, through: :campus_administrators, order: :name

  validates :name, uniqueness: true

end
