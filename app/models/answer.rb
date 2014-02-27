class Answer < ActiveRecord::Base
  belongs_to :answer_set
  belongs_to :metric
  attr_accessible :comments, :value

  validates :value, inclusion: (1..5)
end
