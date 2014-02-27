class AnswerSet < ActiveRecord::Base
  belongs_to :user
  has_many :answers

  attr_accessible :answer_attributes

  accepts_nested_attributes_for :answers
end
