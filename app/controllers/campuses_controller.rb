class CampusesController < ApplicationController
  load_and_authorize_resource

  # GET /campuses
  # GET /campuses.json
  def index
    @campuses = current_user.accessible_campuses

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @campuses }
    end
  end

  # GET /campuses/1
  # GET /campuses/1.json
  def show
    @campus = current_user.accessible_campuses.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @campus }
    end
  end

  # GET /campuses/new
  # GET /campuses/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @campus }
    end
  end

  # GET /campuses/1/edit
  def edit
    @campus = current_user.accessible_campuses.find(params[:id])
  end

  # POST /campuses
  # POST /campuses.json
  def create
    respond_to do |format|
      if @campus.save
        format.html { redirect_to @campus, notice: 'Campus was successfully created.' }
        format.json { render json: @campus, status: :created, location: @campus }
      else
        format.html { render action: "new" }
        format.json { render json: @campus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /campuses/1
  # PUT /campuses/1.json
  def update
    @campus = current_user.accessible_campuses.find(params[:id])

    respond_to do |format|
      if @campus.update_attributes(params[:campus])
        format.html { redirect_to @campus, notice: 'Campus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @campus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campuses/1
  # DELETE /campuses/1.json
  def destroy
    @campus = current_user.accessible_campuses.find(params[:id])
    @campus.destroy

    respond_to do |format|
      format.html { redirect_to campuses_url }
      format.json { head :no_content }
    end
  end

end
