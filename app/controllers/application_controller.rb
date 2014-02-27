class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_answer_set


  private
  def setup_answer_set
    @answer_set = AnswerSet.from_last_set_for(current_user)
  end
end
