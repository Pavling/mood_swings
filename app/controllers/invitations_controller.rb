class InvitationsController < Devise::InvitationsController

  before_filter :load_and_authorize, only: [:new, :create]

  private
  def load_and_authorize
    authorize! :invite, User
    @cohorts = current_user.invitable_cohorts
  end

end