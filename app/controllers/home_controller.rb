class HomeController < ApplicationController
  before_filter :check_for_currently_running!

  def index
  end

end