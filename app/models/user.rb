class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :name, :password, :password_confirmation, :remember_me, :skip_email_reminders, :cohort_id

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

  def last_answer_set
    answer_sets.order(:created_at).reverse_order.first
  end

  def default_cohort_granularity
    admin? || cohort_admin? ? :cohort : :person
  end

  def invitable_cohorts
    accessible_cohorts.current_and_future
  end

  def accessible_cohorts
    return @accessible_cohorts if @accessible_cohorts
    cohort_ids = [
      (Cohort.scoped.pluck(:id) if admin?),
      (campus.cohorts.pluck(:id) if campus_admin?),
      (administered_cohorts.pluck(:id) if cohort_admin?),
      cohort_id
    ].flatten.delete_if(&:blank?)
   @accessible_cohorts = Cohort.where(id: cohort_ids)
  end

  def accessible_campuses
    return @accessible_campuses if @accessible_campuses
    campus_ids = [
      (Campus.scoped.pluck(:id) if admin?),
      (administered_campuses.pluck(:id) if campus_admin?),
      (administered_cohorts.pluck(:campus_id) if cohort_admin?)
    ].flatten.delete_if(&:blank?)
   @accessible_campuses = Campus.where(id: campus_ids)
  end

  def accessible_answer_sets
    # TODO: Once some tests are in place, these four lines might replace what's below (but without tests it's hard to be sure I'm not breaking it :-/
    # administered_cohort_answer_sets_sql = AnswerSet.where(cohort_id: accessible_cohorts.map(&:id)).to_sql
    # own_answer_sets_sql = answer_sets.to_sql
    # answer_set_ids = AnswerSet.find_by_sql("#{administered_cohort_answer_sets_sql} UNION #{own_answer_sets_sql}").map(&:id)
    # AnswerSet.where(id: answer_set_ids)

    if admin?
      AnswerSet.scoped
    else
      administered_cohort_answer_sets_sql = AnswerSet.select('answer_sets.id').joins(cohort: :administrators).where(cohort_administrators: {administrator_id: id}).to_sql
      own_answer_sets_sql = answer_sets.select(:id).to_sql

      answer_set_ids = AnswerSet.find_by_sql("#{administered_cohort_answer_sets_sql} UNION #{own_answer_sets_sql}").map(&:id)
      AnswerSet.where(id: answer_set_ids)
    end
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

end
