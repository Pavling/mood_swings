class CohortsController < ApplicationController
  load_and_authorize_resource

  before_filter :load_campuses, only: [:new, :create, :edit, :update]

  # GET /cohorts
  # GET /cohorts.json
  def index
    @cohorts = current_user.accessible_cohorts

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cohorts }
    end
  end

  # GET /cohorts/1
  # GET /cohorts/1.json
  def show
    @cohort = current_user.accessible_cohorts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cohort }
    end
  end

  # GET /cohorts/new
  # GET /cohorts/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cohort }
    end
  end

  # GET /cohorts/1/edit
  def edit
    @cohort = current_user.accessible_cohorts.find(params[:id])
  end

  # POST /cohorts
  # POST /cohorts.json
  def create
    respond_to do |format|
      if @cohort.save
        format.html { redirect_to @cohort, notice: 'Cohort was successfully created.' }
        format.json { render json: @cohort, status: :created, location: @cohort }
      else
        format.html { render action: "new" }
        format.json { render json: @cohort.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cohorts/1
  # PUT /cohorts/1.json
  def update
    @cohort = current_user.accessible_cohorts.find(params[:id])

    respond_to do |format|
      if @cohort.update_attributes(params[:cohort])
        format.html { redirect_to @cohort, notice: 'Cohort was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cohort.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cohorts/1
  # DELETE /cohorts/1.json
  def destroy
    @cohort = current_user.accessible_cohorts.find(params[:id])
    @cohort.destroy

    respond_to do |format|
      format.html { redirect_to cohorts_url }
      format.json { head :no_content }
    end
  end

  private
  def load_campuses
    @campuses = current_user.administered_campuses.order(:name)
  end

end
