class Metric < ActiveRecord::Base
  attr_accessible :active, :measure

  has_many :answers

  before_update :ensure_measure_not_changed
  before_destroy :ensure_no_answers_exist

  scope :active, where(active: true)

  validates :active, inclusion: { in: [true, false] }
  validates :measure, presence: true
  validate :measure_measure_not_changed, on: :update


  private
  def ensure_measure_not_changed
    # raise an error if the validations are bypassed... I *really* don't want measures changed for existing metrics...
    raise "must not alter measures of existing metrics" if measure_changed?
  end

  private
  def measure_measure_not_changed
    errors.add :measure, "must not be changed on existing records" if measure_changed?
  end

  private
  def ensure_no_answers_exist
    if answers.any?
      errors.add :base, "cannot delete metric if it has answers associated"
      return false
    end
  end

end
