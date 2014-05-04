class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :name, :password, :password_confirmation, :remember_me, :skip_email_reminders, :cohort_id

  before_destroy :ensure_no_answer_sets_exist

  has_many :answer_sets
  has_many :answers, through: :answer_sets
  has_many :cohort_administrations, foreign_key: :administrator_id, class_name: 'CohortAdministrator'
  has_many :administered_cohorts, through: :cohort_administrations, source: :cohort
  has_many :campus_administrations, foreign_key: :administrator_id, class_name: 'CampusAdministrator'
  has_many :administered_campuses, through: :campus_administrations, source: :campus
  belongs_to :cohort

  scope :unenrolled, where(cohort_id: nil)

  validates :name, presence: true

  def self.needing_reminder_email
    where("users.id not in (?)", mood_swung_today << 0).joins(:cohort).merge(Cohort.currently_running)
  end

  def self.desiring_email_reminder
    where(skip_email_reminders: false)
  end

  def self.mood_swung_today
    ids = joins(:answer_sets).where("answer_sets.created_at > ?", Time.now - 1.day).map(&:id)
    where(id: ids)
  end

  def first_name
    name.to_s.split.first
  end

  def last_answer_set
    answer_sets.order(:created_at).reverse_order.first
  end

  def default_cohort_granularity
    admin? || cohort_admin? ? :cohort : :person
  end

  def default_cohort_ids_for_filter
    # return the ids of the currently running, accessible cohorts - but if there's none running, return the ids of all accessible cohorts
    ids = accessible_cohorts.currently_running.pluck(:id)
    ids = ids.any? ? ids : accessible_cohorts.pluck(:id)
    ids.map(&:to_s)
  end

  def invitable_cohorts
    accessible_cohorts.current_and_future
  end

  def accessible_users
    @accessible_users ||= User.scoped if admin?
    return @accessible_users if @accessible_users

    cohort_ids = [
      administered_campuses.flat_map { |campus| campus.cohorts.pluck(:id) },
      administered_cohorts.pluck(:cohort_id)
    ]
    @accessible_users = User.where(cohort_id: cohort_ids)
  end

  def accessible_cohorts
    return @accessible_cohorts if @accessible_cohorts
    cohort_ids = [
      (Cohort.scoped.pluck(:id) if admin?),
      administered_campuses.flat_map { |campus| campus.cohorts.pluck(:id) },
      administered_cohorts.pluck(:id),
      cohort_id
    ].flatten.delete_if(&:blank?)
   @accessible_cohorts = Cohort.where(id: cohort_ids)
  end

  def accessible_cohorts_by_campus
    @accessible_cohorts_by_campus ||= accessible_cohorts.includes(:campus).group_by(&:campus)
  end

  def accessible_campuses
    return @accessible_campuses if @accessible_campuses
    campus_ids = [
      (Campus.scoped.pluck(:id) if admin?),
      administered_campuses.pluck(:id),
      administered_cohorts.pluck(:campus_id)
    ].flatten.delete_if(&:blank?)
   @accessible_campuses = Campus.where(id: campus_ids)
  end

  def accessible_answer_sets
    return @accessible_answer_sets if @accessible_answer_sets
     answer_set_ids = [
       (AnswerSet.scoped.pluck(:id) if admin?),
       administered_cohorts.flat_map(&:answer_sets).map(&:id),
       answer_set_ids
     ].flatten.delete_if(&:blank?)
    @accessible_answer_sets = AnswerSet.where(id: answer_set_ids)
  end

  def admin?
    role == 'admin'
  end

  def cohort_admin?
    return @cohort_admin if [false, true].include?(@cohort_admin)
    @cohort_admin = cohort_administrations.any?
  end

  def campus_admin?
    return @campus_admin if [false, true].include?(@campus_admin)
    @campus_admin = campus_administrations.any?
  end

  private
  def ensure_no_answer_sets_exist
    if answer_sets.any?
      errors.add :base, "cannot delete user if they have swung their mood"
      return false
    end
  end

end
