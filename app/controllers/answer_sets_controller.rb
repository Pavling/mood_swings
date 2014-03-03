class AnswerSetsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  # GET /answer_sets
  # GET /answer_sets.json
  def index
    # TODO: Gotta be able to replace all this imperative scoping with `Ransack` or summit...

    if current_user.admin?
      @answer_sets = AnswerSet.scoped
    else
      @answer_sets = current_user.answer_sets
    end

    if params[:from_date].present?
      @answer_sets = @answer_sets.where("created_at >= ?", params[:from_date])
    end
    if params[:to_date].present?
      @answer_sets = @answer_sets.where("created_at <= ?", params[:to_date])
    end


    # setup the core query of the answer_set data
    @chart_data = @answer_sets.select('avg(answers.value) as value').joins(:answers)


    # set the granularity of the data as required
    @chart_data = case params[:granularity].to_s.downcase
      when 'person'
        # remove the granularity of seeing the individual metric - instead, show each user's average for the set
        @chart_data.select('answer_sets.user_id as metric_id, answer_sets.user_id as user_id, users.email as label').group('answer_sets.user_id, users.email').joins(:user)

      when 'class'
        authorize! :granularity_by_class, AnswerSet
        @chart_data.select("'class' as metric_id, 'class' as user_id, 'class' as label")

      else
        # default to grouping as finely-grained as possible - right down to the individual metric
        @chart_data.select("answers.metric_id as metric_id, answer_sets.user_id as user_id, users.email || ': ' || metrics.measure as label").group("answers.metric_id, answer_sets.user_id, users.email || ': ' || metrics.measure").joins(:user, answers: :metric)
    end


    # group the data into days/weeks if required
    @chart_data = case params[:group].to_s.downcase
      when 'hour'
        @x_labels = 'hour'
        @chart_data.select("date_trunc('hour', answer_sets.created_at) as created_at").group("date_trunc('hour', answer_sets.created_at)")

      when 'day'
        @x_labels = 'day'
        @chart_data.select('DATE(answer_sets.created_at) as created_at').group('DATE(answer_sets.created_at)')

      when 'week'
        # TODO: the week-grouping chart labels get fubard... try to sort them
        @x_labels = 'day'
        @chart_data.select('EXTRACT(YEAR FROM answer_sets.created_at)::text || EXTRACT(WEEK FROM answer_sets.created_at)::text as created_at').group('EXTRACT(YEAR FROM answer_sets.created_at)::text || EXTRACT(WEEK FROM answer_sets.created_at)::text')

      else
        @chart_data.select('answer_sets.created_at as created_at').group('answer_sets.created_at')
    end


    @data = chart_data(@chart_data)
    @keys = chart_data_keys(@chart_data)
    @labels = chart_data_labels(@chart_data)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chart_data }
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
        format.html { redirect_to root_path, notice: 'Your current mood has been recorded. Thank you.' }
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


  private
  def chart_data(data)
    # collate all of the data for each given created_at value (TODO: Should be able to replace with a group-by)
    data.inject({}) do |memo, datum|
      date_format = case params[:group]
        when 'day'
          '%Y-%m-%d'
        when 'week'
          '%Y-%m-%d'
        else
          '%Y-%m-%d %H:%M:%S'
      end

      timestamp = datum.created_at.strftime(date_format)

      memo[timestamp] ||= {timestamp: timestamp}
      memo[timestamp]["#{datum.user_id}##{datum.metric_id}"] = datum.value.to_f.round(1)
      memo
    end.values
  end

  private
  def chart_data_keys(data)
    data.map do |datum|
      datum.user_id.to_s + '#' + datum.metric_id.to_s
    end.uniq
  end

  private
  def chart_data_labels(data)
    data.map(&:label)
  end


end
