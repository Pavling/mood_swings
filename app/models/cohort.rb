class Cohort < ActiveRecord::Base
  attr_accessible :name, :start_on, :end_on

  has_many :students, class_name: 'User'
  has_many :answer_sets

  validates :name, presence: true
  validates :start_on, presence: true
  validates :end_on, presence: true
  validate :validate_end_on_after_start_on


  def validate_end_on_after_start_on
    errors.add(:end_on, "cannot be older than start date") if end_on && start_on && end_on < start_on
  end

end
