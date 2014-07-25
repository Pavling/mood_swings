class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_answer_set

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  rescue_from MoodSwings::NotInCurrentlyRunningCohort do |exception|
    redirect_to swingings_path, alert: "you are not in a cohort that's currently running"
  end

  private
  def setup_answer_set
    @answer_set = AnswerSet.from_last_set_for_user(current_user)
  end

  private
  def check_for_currently_running!
    if current_user && 
      !current_user.cohort.try(:currently_running?) && 
      !current_user.admin? &&
      !current_user.campus_admin? &&
      !current_user.cohort_admin?
      raise MoodSwings::NotInCurrentlyRunningCohort
    end
  end

end
