class InvitationsController < Devise::InvitationsController

  # overloading the invitations process to populate an instance variable for the cohorts that are available to invite people to
  def new
    @cohorts = current_user.accessible_cohorts.current_and_future
    super
  end

  def create
    @cohorts = current_user.accessible_cohorts.current_and_future
    super
  end

end