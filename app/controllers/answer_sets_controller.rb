class AnswerSetsController < ApplicationController
  load_and_authorize_resource

  # GET /answer_sets
  # GET /answer_sets.json
  def index
    if current_user.admin?
      @answer_sets = AnswerSet.all
    else
      @answer_sets = current_user.answer_sets
    end

    @answer_sets = case params[:group].to_s.downcase
    when 'person'
      
    else
      @answer_sets
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @answer_sets }
    end
  end

  # GET /answer_sets/1
  # GET /answer_sets/1.json
  def show
    @answer_set = AnswerSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @answer_set }
    end
  end

  # GET /answer_sets/new
  # GET /answer_sets/new.json
  def new
    @answer_set = AnswerSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @answer_set }
    end
  end

  # GET /answer_sets/1/edit
  def edit
    @answer_set = AnswerSet.find(params[:id])
  end

  # POST /answer_sets
  # POST /answer_sets.json
  def create
    @answer_set = AnswerSet.new(params[:answer_set])
    @answer_set.user = current_user
    
    respond_to do |format|
      if @answer_set.save
        format.html { redirect_to home_path, notice: 'Answer set was successfully created.' }
        format.json { render json: @answer_set, status: :created, location: @answer_set }
      else
        format.html { render "pages/home" }
        format.json { render json: @answer_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /answer_sets/1
  # PUT /answer_sets/1.json
  def update
    @answer_set = AnswerSet.find(params[:id])

    respond_to do |format|
      if @answer_set.update_attributes(params[:answer_set])
        format.html { redirect_to @answer_set, notice: 'Answer set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @answer_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answer_sets/1
  # DELETE /answer_sets/1.json
  def destroy
    @answer_set = AnswerSet.find(params[:id])
    @answer_set.destroy

    respond_to do |format|
      format.html { redirect_to answer_sets_url }
      format.json { head :no_content }
    end
  end
end
