class HomeController < ApplicationController

  def index
    if current_user && !current_user.cohort.try(:currently_running?)
      redirect_to answer_sets_path, notice: "you are not in a cohort that's currently running" and return
    end
  end

end