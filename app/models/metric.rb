class Metric < ActiveRecord::Base
  attr_accessible :active, :measure

  has_many :answers

  before_update :ensure_measure_not_changed # in case validations are bypassed...
  before_destroy :ensure_no_answers_exist

  scope :active, where(active: true)

  validates :active, inclusion: { in: [true, false] }
  validates :measure, presence: true
  validate :ensure_measure_not_changed, on: :update

  private
  def ensure_measure_not_changed
    if measure_changed?
      errors.add :measure, "must not be changed on existing records"
      return false
    end
  end

  private
  def ensure_no_answers_exist
    if answers.any?
      errors.add :base, "cannot delete metric if it has answers associated"
      return false
    end
  end

end
