class RegistrationsController < Devise::RegistrationsController

  # overloading the registrations process to prevent new users signing up - instead to rely on the invitations
  # it might be worth switching to just blatting the routes instead...
  def new
    redirect_to new_user_session_path, notice: 'Please request a login from GA'
  end

  def create
    redirect_to new_user_session_path, notice: 'Please request a login from GA'
  end
end