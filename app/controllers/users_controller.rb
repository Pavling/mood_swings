class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = current_user.accessible_users.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end    
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def edit
    @cohorts = current_user.invitable_cohorts
  end

  def update
    @user.attributes = params[:user]
    authorize! :alter_email, @user if @user.email_changed?

    @cohorts = current_user.invitable_cohorts
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

end
