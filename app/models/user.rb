class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :skip_email_reminders, :cohort_id


  has_many :answer_sets
  has_many :answers, through: :answer_sets
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

  def admin?
    role == 'admin'
  end
end
