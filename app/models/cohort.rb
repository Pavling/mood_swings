class Cohort < ActiveRecord::Base
  attr_accessible :name, :start_on, :end_on, :student_ids, :administrator_ids, :campus_id, :skip_email_reminders, :allow_users_to_manage_email_reminders

  belongs_to :campus
  has_many :students, class_name: 'User', order: :name
  has_many :answer_sets
  has_many :cohort_administrators
  has_many :administrators, through: :cohort_administrators, order: :name

  before_destroy :ensure_no_answer_sets_exist

  default_scope order(:name)
  scope :currently_running, lambda { where("cohorts.start_on <= :today AND cohorts.end_on >= :today", today: Date.today) }
  scope :future, lambda { where("cohorts.start_on > :today", today: Date.today) }

  validates :name, presence: true
  validates :name, uniqueness: { scope: :campus_id }
  validates :start_on, presence: true
  validates :end_on, presence: true
  validates :campus_id, presence: true
  validate :validate_end_on_after_start_on

  def self.current_and_future
    where("cohorts.end_on >= :today", today: Date.today)
  end

  def currently_running?
    Cohort.currently_running.include?(self)
  end

  private
  def validate_end_on_after_start_on
    errors.add(:end_on, "cannot be older than start date") if end_on && start_on && end_on < start_on
  end

  private
  def ensure_no_answer_sets_exist
    if answer_sets.any?
      errors.add :base, "you cannot delete this cohort as users have given mood swings for it"
      return false
    end
  end
end
