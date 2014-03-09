class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me


  has_many :answer_sets
  has_many :answers, through: :answer_sets

  def self.needing_reminder_email
    where("users.id not in (?)", mood_swung_today << 0)
  end

  def self.mood_swung_today
    ids = joins(:answer_sets).where("answer_sets.created_at > ?", Time.now - 1.day).map(&:id)
    where(id: ids)
  end

  def admin?
    role == 'admin'
  end
end
