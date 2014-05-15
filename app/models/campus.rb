class Campus < ActiveRecord::Base
  attr_accessible :name, :administrator_ids

  has_many :cohorts
  has_many :campus_administrators
  has_many :administrators, through: :campus_administrators, order: :name

  before_destroy :ensure_no_cohorts_exist

  validates :name, presence: true
  validates :name, uniqueness: true

  private
  def ensure_no_cohorts_exist
    if cohorts.any?
      errors.add :base, "you cannot delete this campus as it has cohorts registered at it"
      return false
    end
  end
end
