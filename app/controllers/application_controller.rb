class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_answer_set


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  private
  def setup_answer_set
    @answer_set = AnswerSet.from_last_set_for_user(current_user)
  end
end
