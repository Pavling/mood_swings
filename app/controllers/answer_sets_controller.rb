class AnswerSetsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :check_for_currently_running!, only: :create

  # GET /answer_sets
  # GET /answer_sets.json
  def index
    case params[:granularity].to_s.downcase
      when 'cohort'
        authorize! :granularity_by_cohort, AnswerSet
      when 'campus'
        authorize! :granularity_by_campus, AnswerSet
    end

    # set default values into params
    params[:granularity] ||= current_user.default_cohort_granularity
    params[:group] ||= :day
    params[:cohort_ids] ||= current_user.default_cohort_ids_for_filter

    @answer_sets = current_user.accessible_answer_sets.for_index(params)

    @chart_data = @answer_sets.for_chart(params)

    @data = chart_data(@chart_data)
    @keys = chart_data_keys(@chart_data)
    @labels = chart_data_labels(@chart_data)
    @x_labels = case params[:group].to_s.downcase
      when 'hour'
        'hour'
      when 'day'
        'day'
      when 'week'
        'month'
      end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chart_data }
    end
  end

  # POST /answer_sets
  # POST /answer_sets.json
  def create
    @answer_set = AnswerSet.new(params[:answer_set])
    @answer_set.user = current_user
    @answer_set.cohort = current_user.cohort
    
    respond_to do |format|
      if @answer_set.save
        format.html { redirect_to root_path, notice: 'Your current mood has been recorded. Thank you.' }
        format.json { render json: @answer_set, status: :created, location: @answer_set }
      else
        format.html { redirect_to root_path, alert: @answer_set.errors.full_messages.join(' ') }
        format.json { render json: @answer_set.errors, status: :unprocessable_entity }
      end
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
          datum.created_at = Date.parse("#{datum.created_at_year}-01-01") + (datum.created_at_week.to_i*7).days
          '%Y-%m-%d'
        else
          '%Y-%m-%d %H:%M:%S'
      end

      timestamp = datum.created_at.strftime(date_format)

      memo[timestamp] ||= {timestamp: timestamp}
      memo[timestamp]["#{datum.cohort_id}##{datum.user_id}##{datum.metric_id}"] = datum.value.to_f.round(1)
      memo
    end.values
  end

  private
  def chart_data_keys(data)
    keys_and_data_for(data).map(&:keys).flatten
  end

  private
  def chart_data_labels(data)
    keys_and_data_for(data).map(&:values).flatten
  end

  private
  def keys_and_data_for(data)
    data.map do |datum|
      {datum.cohort_id.to_s + '#' + datum.user_id.to_s + '#' + datum.metric_id.to_s => datum.label }
    end.uniq
  end

end
