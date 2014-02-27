class Answer < ActiveRecord::Base
  belongs_to :answer_set
  belongs_to :metric
  attr_accessible :comments, :value, :metric_id

  validates :value, inclusion: (1..5)
  validates :metric_id, uniqueness: {scope: :answer_set_id}
  validates :metric_id, presence: true


  def knob_data
    {
      fgColor: "#66CC66",
      angleOffset: -125,
      angleArc: 250,
      width: 75,
      height: 75,
      min: 1,
      max: 5,
      cursor: true,
      linecap: :round,
    }
  end
end
