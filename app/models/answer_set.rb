class AnswerSet < ActiveRecord::Base
  belongs_to :cohort
  belongs_to :user
  has_many :answers, dependent: :destroy

  before_destroy :prevent_destroy
  
  scope :with_comments, includes(:answers).where("answers.comments > ''")
  scope :last_five_minutes, lambda { where('created_at > ?', 5.minutes.ago)}

  attr_accessible :answers_attributes

  accepts_nested_attributes_for :answers

  validates :cohort_id, presence: true
  validate :not_swung_in_the_last_five_minutes


  def self.populated_with_answers
    answer_set = new
    Metric.active.each do |metric|
      answer_set.answers.build(metric_id: metric.id)
    end
    answer_set
  end

  def self.for_index(params)
    # restrict the default list of answer_sets to be the accessible ones for the user, filtered by the select ones from the view
    answer_sets = scoped.where(cohort_id: params[:cohort_ids])

    if params[:from_date].present?
      answer_sets = answer_sets.where("answer_sets.created_at >= ?", params[:from_date])
    end
    if params[:to_date].present?
      aanswer_sets = answer_sets.where("answer_sets.created_at <= ?", params[:to_date])
    end

    answer_sets
  end

  def self.for_chart(params)
    # setup the core query of the answer_set data
    chart_data = scoped.select('avg(answers.value) as value').joins(:answers, cohort: :campus)


    # set the granularity of the data as required
    chart_data = case params[:granularity].to_s.downcase
      when 'person'
        # remove the granularity of seeing the individual metric - instead, show each user's average for the set
        chart_data.select('cohorts.campus_id as campus_id, answer_sets.cohort_id as cohort_id, answer_sets.user_id as metric_id, answer_sets.user_id as user_id, users.name as label').group('cohorts.campus_id, answer_sets.cohort_id, answer_sets.user_id, users.name').joins(:user)

      when 'cohort'
        chart_data.select("cohorts.campus_id as campus_id, answer_sets.cohort_id as cohort_id, 'cohort' as metric_id, 'cohort' as user_id, cohorts.name as label").group('cohorts.campus_id, answer_sets.cohort_id, cohorts.name')

      when 'campus'
        chart_data.select("cohorts.campus_id as campus_id, 'campus' as cohort_id, 'campus' as metric_id, 'campus' as user_id, campuses.name as label").group('cohorts.campus_id, campuses.name')

      else
        # default to grouping as finely-grained as possible - right down to the individual metric
        chart_data.select("cohorts.campus_id as campus_id, answer_sets.cohort_id as cohort_id, answers.metric_id as metric_id, answer_sets.user_id as user_id, users.name || ': ' || metrics.measure as label").group("cohorts.campus_id, answer_sets.cohort_id, answers.metric_id, answer_sets.user_id, users.name || ': ' || metrics.measure").joins(:user, answers: :metric)
    end
    

    # group the data into days/weeks if required
    chart_data = case params[:group].to_s.downcase
      when 'hour'
        @x_labels = 'hour'
        chart_data.select("date_trunc('hour', answer_sets.created_at) as created_at").group("date_trunc('hour', answer_sets.created_at)")

      when 'day'
        @x_labels = 'day'
        chart_data.select('DATE(answer_sets.created_at) as created_at').group('DATE(answer_sets.created_at)')

      when 'week'
        # TODO: the week-grouping chart labels get fubard... try to sort them
        @x_labels = 'month'
        chart_data.select("EXTRACT(YEAR FROM answer_sets.created_at)::text as created_at_year, EXTRACT(WEEK FROM answer_sets.created_at)::text as created_at_week").group("EXTRACT(YEAR FROM answer_sets.created_at)::text, EXTRACT(WEEK FROM answer_sets.created_at)::text")

      else
        chart_data.select('answer_sets.created_at as created_at').group('answer_sets.created_at')
    end

    chart_data
  end

  private
  def prevent_destroy
    errors.add :base, "you cannot delete answer sets"
    return false
  end

  private
  def chart_color
    @chart_colour ||= "%06x" % (rand * 0xffffff)
  end

  private
  def not_swung_in_the_last_five_minutes
    errors.add :base, "Whoa! You must be very moody! You need to leave at least 5mins between swings." if user && user.answer_sets.last_five_minutes.any?
  end

  private
  def self.from_last_set_for(user)
    answer_set = populated_with_answers

    return answer_set unless user && last_set = user.answer_sets.last

    answer_set.answers.each do |answer|
      if previous_answer = last_set.answers.detect{|a|a.metric_id==answer.metric_id}
        answer.value = previous_answer.value
      end
    end

    answer_set
  end
end
