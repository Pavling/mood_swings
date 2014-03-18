class Cohort < ActiveRecord::Base
  attr_accessible :name, :start_on, :end_on, :student_ids

  has_many :students, class_name: 'User', order: :email
  has_many :answer_sets

  default_scope order(:name)
  scope :currently_running, lambda { where("cohorts.start_on <= :today AND cohorts.end_on >= :today", today: Date.today) }

  validates :name, presence: true
  validates :start_on, presence: true
  validates :end_on, presence: true
  validate :validate_end_on_after_start_on


  def validate_end_on_after_start_on
    errors.add(:end_on, "cannot be older than start date") if end_on && start_on && end_on < start_on
  end

  def currently_running?
    Cohort.currently_running.include?(self)
  end

end
