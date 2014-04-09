class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :skip_email_reminders, :cohort_id


  has_many :answer_sets
  has_many :answers, through: :answer_sets
  has_many :cohort_administrations, foreign_key: :administrator_id, class_name: 'CohortAdministrator'
  has_many :administered_cohorts, through: :cohort_administrations, source: :cohort
  belongs_to :cohort

  scope :unenrolled, where(cohort_id: nil)

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

  def default_cohort_granularity
    admin? || cohort_admin? ? :cohort : :person
  end

  def accessible_cohorts
    case
      when admin?
        Cohort.scoped

      when cohort_admin?
        administered_cohorts

      else
        Cohort.where(id: cohort.id)
    end
  end

  def accessible_answer_sets
    if admin?
      AnswerSet.scoped
    else
      # @answer_sets = current_user.answer_sets
      administered_cohort_answer_sets_sql = AnswerSet.joins(cohort: :administrators).where(cohort_administrators: {administrator_id: id}).to_sql
      own_answer_sets_sql = answer_sets.to_sql

      answer_set_ids = AnswerSet.find_by_sql("#{administered_cohort_answer_sets_sql} UNION #{own_answer_sets_sql}").map(&:id)
      AnswerSet.where(id: answer_set_ids)
    end
  end

  def admin?
    role == 'admin'
  end

  def cohort_admin?
    cohort_administrations.any?
  end

end
