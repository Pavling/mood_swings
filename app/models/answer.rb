class Answer < ActiveRecord::Base
  belongs_to :answer_set
  belongs_to :metric
  attr_accessible :comments, :value

  validates :value, inclusion: (1..5)
  validates :metric_id, uniqueness: {scope: :answer_set_id}
  validates :metric_id, presence: true

end
