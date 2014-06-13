require 'spec_helper'

describe AnswerSet do
  it "has a valid factory" do
    expect(FactoryGirl.build(:answer_set, :with_answers)).to be_valid
  end

  it "cannot be destroyed" do
    answer_set = FactoryGirl.create(:answer_set, :with_answers)
    expect(answer_set.destroy).to be false
  end
  
  it "is invalid without a cohort" do
    expect(FactoryGirl.build(:answer_set, :with_answers, cohort: nil)).to_not be_valid
  end

  it "is invalid without a user" do
    expect(FactoryGirl.build(:answer_set, :with_answers, user: nil)).to_not be_valid
  end

  describe "limit answer sets to have at least five minutes between them" do
    it "must not have another by the same user in the last five minutes" do
      user = FactoryGirl.create(:user)
      answer_set = FactoryGirl.create(:answer_set, :with_answers, user: user)
      answer_set.update_attribute(:created_at, 4.minutes.ago)

      expect(FactoryGirl.build(:answer_set, :with_answers, user: user)).to_not be_valid
    end

    it "can have another by the same user after five minutes" do
      user = FactoryGirl.create(:user)
      old_answer_set = FactoryGirl.create(:answer_set, :with_answers, user: user)
      old_answer_set.update_attribute(:created_at, 5.minutes.ago)

      expect(FactoryGirl.build(:answer_set, :with_answers, user: user)).to be_valid
    end
  end

  describe "ensure there's always at least one answer" do
    it "is invalid with no answers" do

    end



  end

  it "rejects answers set to be `not_applicable`" do
    5.times { FactoryGirl.create(:metric)}

    as = AnswerSet.populated_with_answers
    as.cohort = FactoryGirl.create(:cohort)
    as.user = FactoryGirl.create(:user, cohort: as.cohort)
    as.answers.each { |a| a.value = 5 }
    as.answers.first.not_applicable = true
    as.answers.last.not_applicable = true
    as.save
 
    expect(as.answers.size).to eq 3
  end

  describe '.with_comments' do
    it 'returns all the answer_sets which have answers with commments' do
      no_comment_answer_set = FactoryGirl.build(:answer_set)
      no_comment_answer_set.answers << FactoryGirl.build(:answer, answer_set: no_comment_answer_set)
      no_comment_answer_set.save

      comment_answer_set_1 = FactoryGirl.build(:answer_set)
      comment_answer_set_1.answers << FactoryGirl.build(:answer_with_comments, answer_set: comment_answer_set_1)
      comment_answer_set_1.answers << FactoryGirl.build(:answer, answer_set: comment_answer_set_1)
      comment_answer_set_1.save

      comment_answer_set_2 = FactoryGirl.build(:answer_set)
      comment_answer_set_2.answers << FactoryGirl.build(:answer_with_comments, answer_set: comment_answer_set_2)
      comment_answer_set_2.answers << FactoryGirl.build(:answer_with_comments, answer_set: comment_answer_set_2)
      comment_answer_set_2.save

      expect(AnswerSet.with_comments.sort).to eq [comment_answer_set_1, comment_answer_set_2].sort
    end
  end

  describe '.last_five_minutes' do
    it 'returns all the answer_sets created in the last five minutes' do
      old_answer_set = FactoryGirl.create(:answer_set, :with_answers)
      old_answer_set.update_attribute(:created_at, 5.minutes.ago)

      answer_set = FactoryGirl.create(:answer_set, :with_answers)

      expect(AnswerSet.last_five_minutes).to eq [answer_set]
    end
  end

  describe '.populated_with_answers' do
    it 'returns a new answer set with answers built for all the currently active metrics' do
      5.times { FactoryGirl.create(:metric)}
      2.times { FactoryGirl.create(:metric, active: false)}

      expect(AnswerSet.populated_with_answers.answers.size).to eq 5
    end

  end


  describe '.from_last_set_for_user' do
    before :each do
      @metrics = 5.times.map { FactoryGirl.create(:metric) }

      @user = FactoryGirl.create(:user, cohort: FactoryGirl.create(:cohort))
    end

    it "returns a new answer_set populated with answers of the same values as the user's last swing" do
      answer_set = FactoryGirl.build(:answer_set, user: @user, cohort: @user.cohort)
      answer_set.answers = @metrics.map { |m| FactoryGirl.build(:answer_with_comments, answer_set: answer_set, metric: m) }
      answer_set.update_attribute(:created_at, 20.minutes.ago)

      last_answer_set = FactoryGirl.build(:answer_set, user: @user, cohort: @user.cohort)
      last_answer_set.answers = @metrics.map { |m| FactoryGirl.build(:answer_with_comments, answer_set: last_answer_set, metric: m) }
      last_answer_set.update_attribute(:created_at, 10.minutes.ago)
      
      new_answer_set = AnswerSet.from_last_set_for_user(@user)

      new_answer_set.answers.each do |answer|
        last_answer = last_answer_set.answers.detect { |a| a.metric_id == answer.metric_id }
        expect([answer.value, answer.comments]).to eq [last_answer.value, nil]
      end

    end

    it "returns a new answer_set populated with default answers if the user has never swung" do
      new_answer_set = AnswerSet.from_last_set_for_user(@user)

      new_answer_set.answers.each do |answer|
        expect([answer.value, answer.comments]).to eq [nil, nil]
      end
    end
  end


  describe '.for_index' do
    before :each do
      setup_dummy_data 
    end

    describe 'for all cohorts' do
      before :each do
        @params = { cohort_ids: Cohort.all.map(&:id) }
      end

      it 'returns all the answer sets for all cohorts' do
        ids = @answer_sets.map(&:id).sort
        expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
      end

      describe 'with a from_date' do
        it 'returns only the answer sets since the from_date' do
          @params[:from_date] = 10.days.ago
          ids = @answer_sets.select{|as| as.created_at >= @params[:from_date]}.map(&:id).sort
          expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
        end
      end

      describe 'with a to_date' do
        it 'returns only the answer sets until the to_date' do
          @params[:to_date] = 5.days.ago
          ids = @answer_sets.select{|as| as.created_at <= @params[:to_date]}.map(&:id).sort
          expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
        end
      end

      describe 'with a from_date and to_date' do
        it 'returns only the answer sets between the from_date and the to_date' do
          @params[:from_date] = 10.days.ago
          @params[:to_date] = 5.days.ago
          ids = @answer_sets.select{|as| as.created_at >= @params[:from_date] && as.created_at <= @params[:to_date]}.map(&:id).sort
          expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
        end
      end
    end

    describe 'for a subset of cohorts' do
      before :each do
        @params = { cohort_ids: [@cohort1, @cohort4].map(&:id) }
        @answer_sets = @answer_sets.select{|as| [@cohort1, @cohort4].include?(as.cohort)}
      end

      it 'returns all the answer sets for the subset of cohorts' do
        ids =  @answer_sets.map(&:id).sort
        expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
      end

      describe 'with a from_date' do
        it 'returns only the answer sets since the from_date' do
          @params[:from_date] = 10.days.ago
          ids = @answer_sets.select{|as| as.created_at >= @params[:from_date]}.map(&:id).sort
          expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
        end
      end

      describe 'with a to_date' do
        it 'returns only the answer sets until the to_date' do
          @params[:to_date] = 5.days.ago
          ids = @answer_sets.select{|as| as.created_at <= @params[:to_date]}.map(&:id).sort
          expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
        end
      end

      describe 'with a from_date and to_date' do
        it 'returns only the answer sets between the from_date and the to_date' do
          @params[:from_date] = 10.days.ago
          @params[:to_date] = 5.days.ago
          ids = @answer_sets.select{|as| as.created_at >= @params[:from_date] && as.created_at <= @params[:to_date]}.map(&:id).sort
          expect(AnswerSet.for_index(@params).map(&:id).sort).to eq ids
        end
      end
    end

  end


  describe '.for_chart' do
    before :each do
      setup_dummy_data
      AnswerSet.order(:created_at)[0..9].each(&:delete)
      @params = {}
    end

    describe 'granularity options' do
      describe 'person' do
        before :each do
          @params[:granularity] = 'person'
        end

        describe 'group options' do
          describe 'hour' do
            before :each do
              @params[:group] = 'hour'
            end

            it 'gets the right data' do 
              data = [{"value"=>"2.2000000000000000",
                    "label"=>"user1",
                    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user2",
                    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user3",
                    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user4",
                    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user5",
                    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user1",
                    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user2",
                    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user3",
                    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user4",
                    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
                   {"value"=>"2.2000000000000000",
                    "label"=>"user5",
                    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone}]

              expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
           end

         end

         describe 'day' do
           before :each do
             @params[:group] = 'day'
           end

           it 'gets the right data' do
             data =  [{"value"=>"2.2000000000000000",
      "label"=>"user1",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user2",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user3",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user4",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user5",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user1",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user2",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user3",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user4",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"user5",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone}]

             expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'week' do
          before :each do
            @params[:group] = 'week'
          end

         it 'gets the right data' do
           data = [{"label"=>"user1", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
   {"label"=>"user2", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
   {"label"=>"user3", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
   {"label"=>"user4", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
   {"label"=>"user5", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
   {"label"=>"user1", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
   {"label"=>"user2", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
   {"label"=>"user3", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
   {"label"=>"user4", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
   {"label"=>"user5", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')}]

           expect(chart_data_to_hash(AnswerSet.order(:created_at_year, :created_at_week, :label).for_chart(@params), %w(label created_at_year created_at_week))).to eq data
        end
        end

        describe 'moment' do
          before :each do
            @params[:group] = 'moment'
          end

          it 'gets the right data' do
            data = [{"value"=>"2.2000000000000000",
  "label"=>"user1",
  "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user2",
  "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user3",
  "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user4",
  "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user5",
  "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user1",
  "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user2",
  "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user3",
  "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user4",
  "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
 {"value"=>"2.2000000000000000",
  "label"=>"user5",
  "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end
        
      end
    end

    describe 'cohort' do
      before :each do
        @params[:granularity] = 'cohort'
      end

      describe 'group options' do
        describe 'hour' do
          before :each do
            @params[:group] = 'hour'
          end

          it 'gets the right data' do
            data = [{"value"=>"2.2000000000000000",
    "label"=>"cohort1",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort2",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort3",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort4",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort1",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort2",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort3",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort4",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'day' do
          before :each do
            @params[:group] = 'day'
          end

                  it 'gets the right data' do
                    data = [{"value"=>"2.2000000000000000",
      "label"=>"cohort1",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort2",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort3",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort4",
      "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort1",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort2",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort3",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
     {"value"=>"2.2000000000000000",
      "label"=>"cohort4",
      "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone}]

                    expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
                 end
               end

        describe 'week' do
          before :each do
            @params[:group] = 'week'
          end

          it 'gets the right data' do
            data = [{"label"=>"cohort1", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
  {"label"=>"cohort2", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
  {"label"=>"cohort3", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
  {"label"=>"cohort4", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
  {"label"=>"cohort1", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
  {"label"=>"cohort2", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
  {"label"=>"cohort3", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
  {"label"=>"cohort4", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at_year, :created_at_week, :label).for_chart(@params), %w(label created_at_year created_at_week))).to eq data
          end
        end

        describe 'moment' do
          before :each do
            @params[:group] = 'moment'
          end

                 it 'gets the right data' do
                   data = [{"value"=>"2.2000000000000000",
    "label"=>"cohort1",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort2",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort3",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort4",
    "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort1",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort2",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort3",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"cohort4",
    "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone}]

                   expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
                 end
        end
      end
    end

    describe 'campus' do
      before :each do
        @params[:granularity] = 'campus'
      end

      describe 'group options' do
        describe 'hour' do
          before :each do
            @params[:group] = 'hour'
          end

                it 'gets the right data' do
               data = [{"value"=>"2.2000000000000000",
           "label"=>"campus1",
           "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
          {"value"=>"2.2000000000000000",
           "label"=>"campus2",
           "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
          {"value"=>"2.2000000000000000",
           "label"=>"campus1",
           "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
          {"value"=>"2.2000000000000000",
           "label"=>"campus2",
           "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone}]

               expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
               end
               end

        describe 'day' do
          before :each do
            @params[:group] = 'day'
          end

          it 'gets the right data' do
            data = [{"value"=>"2.2000000000000000",
    "label"=>"campus1",
    "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"campus2",
    "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"campus1",
    "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
   {"value"=>"2.2000000000000000",
    "label"=>"campus2",
    "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'week' do
          before :each do
            @params[:group] = 'week'
          end

          it 'gets the right data' do
            data = [{"label"=>"campus1", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
  {"label"=>"campus2", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
  {"label"=>"campus1", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
  {"label"=>"campus2", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at_year, :created_at_week, :label).for_chart(@params), %w(label created_at_year created_at_week))).to eq data
          end
        end

        describe 'moment' do
          before :each do
            @params[:group] = 'moment'
          end

          it 'gets the right data' do
            data = [{"value"=>"2.2000000000000000",
           "label"=>"campus1",
           "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
          {"value"=>"2.2000000000000000",
           "label"=>"campus2",
           "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
          {"value"=>"2.2000000000000000",
           "label"=>"campus1",
           "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
          {"value"=>"2.2000000000000000",
           "label"=>"campus2",
           "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end
      end
    end


    describe 'metric' do
      before :each do
        @params[:granularity] = 'metric'
        AnswerSet.where(user_id: [@user1.id, @user2.id, @user3.id]).each do |as|
          as.answers.each(&:delete)
          as.delete
        end
      end

      describe 'group options' do
        describe 'hour' do
          before :each do
            @params[:group] = 'hour'
          end

          it 'gets the right data' do
            data = [{"value"=>"1.00000000000000000000",
         "label"=>"metric1",
         "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
        {"value"=>"2.0000000000000000",
         "label"=>"metric2",
         "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
        {"value"=>"3.0000000000000000",
         "label"=>"metric3",
         "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
        {"value"=>"4.0000000000000000",
         "label"=>"metric4",
         "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
        {"value"=>"1.00000000000000000000",
         "label"=>"metric5",
         "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
        {"value"=>"1.00000000000000000000",
         "label"=>"metric1",
         "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
        {"value"=>"2.0000000000000000",
         "label"=>"metric2",
         "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
        {"value"=>"3.0000000000000000",
         "label"=>"metric3",
         "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
        {"value"=>"4.0000000000000000",
         "label"=>"metric4",
         "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
        {"value"=>"1.00000000000000000000",
         "label"=>"metric5",
         "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'day' do
          before :each do
            @params[:group] = 'day'
          end

          it 'gets the right data' do
            data = [{"value"=>"1.00000000000000000000",
               "label"=>"metric1",
               "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"2.0000000000000000",
               "label"=>"metric2",
               "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"3.0000000000000000",
               "label"=>"metric3",
               "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"4.0000000000000000",
               "label"=>"metric4",
               "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"1.00000000000000000000",
               "label"=>"metric5",
               "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"1.00000000000000000000",
               "label"=>"metric1",
               "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"2.0000000000000000",
               "label"=>"metric2",
               "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"3.0000000000000000",
               "label"=>"metric3",
               "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"4.0000000000000000",
               "label"=>"metric4",
               "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
              {"value"=>"1.00000000000000000000",
               "label"=>"metric5",
               "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'week' do
          before :each do
            @params[:group] = 'week'
          end

          it 'gets the right data' do
            data = [{"label"=>"metric1", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
             {"label"=>"metric2", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
             {"label"=>"metric3", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
             {"label"=>"metric4", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
             {"label"=>"metric5", "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
             {"label"=>"metric1", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
             {"label"=>"metric2", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
             {"label"=>"metric3", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
             {"label"=>"metric4", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
             {"label"=>"metric5", "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at_year, :created_at_week, :label).for_chart(@params), %w(label created_at_year created_at_week))).to eq data
          end
        end

        describe 'moment' do
          before :each do
            @params[:group] = 'moment'
          end

          it 'gets the right data' do
            data = [{"value"=>"1.00000000000000000000",
               "label"=>"metric1",
               "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
              {"value"=>"2.0000000000000000",
               "label"=>"metric2",
               "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
              {"value"=>"3.0000000000000000",
               "label"=>"metric3",
               "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
              {"value"=>"4.0000000000000000",
               "label"=>"metric4",
               "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
              {"value"=>"1.00000000000000000000",
               "label"=>"metric5",
               "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
              {"value"=>"1.00000000000000000000",
               "label"=>"metric1",
               "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
              {"value"=>"2.0000000000000000",
               "label"=>"metric2",
               "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
              {"value"=>"3.0000000000000000",
               "label"=>"metric3",
               "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
              {"value"=>"4.0000000000000000",
               "label"=>"metric4",
               "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
              {"value"=>"1.00000000000000000000",
               "label"=>"metric5",
               "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone}]
            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end
      end
    end


    describe 'person_metric' do
      before :each do
        @params[:granularity] = 'person_metric'
        AnswerSet.where(user_id: [@user1.id, @user2.id, @user3.id]).each do |as|
          as.answers.each(&:delete)
          as.delete
        end
      end

      describe 'group options' do
        describe 'hour' do
          before :each do
            @params[:group] = 'hour'
          end

          it 'gets the right data' do
            data = [{"value"=>"1.00000000000000000000",
       "label"=>"user4: metric1",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"2.0000000000000000",
       "label"=>"user4: metric2",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"3.0000000000000000",
       "label"=>"user4: metric3",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"4.0000000000000000",
       "label"=>"user4: metric4",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user4: metric5",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user5: metric1",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"2.0000000000000000",
       "label"=>"user5: metric2",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"3.0000000000000000",
       "label"=>"user5: metric3",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"4.0000000000000000",
       "label"=>"user5: metric4",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user5: metric5",
       "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user4: metric1",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"2.0000000000000000",
       "label"=>"user4: metric2",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"3.0000000000000000",
       "label"=>"user4: metric3",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"4.0000000000000000",
       "label"=>"user4: metric4",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user4: metric5",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user5: metric1",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"2.0000000000000000",
       "label"=>"user5: metric2",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"3.0000000000000000",
       "label"=>"user5: metric3",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"4.0000000000000000",
       "label"=>"user5: metric4",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone},
      {"value"=>"1.00000000000000000000",
       "label"=>"user5: metric5",
       "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.to_s).in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'day' do
          before :each do
            @params[:group] = 'day'
          end

          it 'gets the right data' do
            data = [{"value"=>"1.00000000000000000000",
             "label"=>"user4: metric1",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user4: metric2",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user4: metric3",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user4: metric4",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user4: metric5",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric1",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user5: metric2",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user5: metric3",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user5: metric4",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric5",
             "created_at"=>@start_of_week.ago(8.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user4: metric1",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user4: metric2",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user4: metric3",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user4: metric4",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user4: metric5",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric1",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user5: metric2",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user5: metric3",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user5: metric4",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric5",
             "created_at"=>@start_of_week.ago(1.days).utc.beginning_of_day.in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end

        describe 'week' do
          before :each do
            @params[:group] = 'week'
          end

          it 'gets the right data' do
            data = [{"label"=>"user4: metric1",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user4: metric2",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user4: metric3",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user4: metric4",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user4: metric5",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user5: metric1",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user5: metric2",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user5: metric3",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user5: metric4",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user5: metric5",
            "created_at_year"=>@start_of_week.ago(7.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(7.days).strftime('%W')},
           {"label"=>"user4: metric1",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user4: metric2",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user4: metric3",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user4: metric4",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user4: metric5",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user5: metric1",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user5: metric2",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user5: metric3",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user5: metric4",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')},
           {"label"=>"user5: metric5",
            "created_at_year"=>@start_of_week.ago(0.days).to_date.year.to_s, "created_at_week"=>@start_of_week.ago(0.days).strftime('%W')}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at_year, :created_at_week, :label).for_chart(@params), %w(label created_at_year created_at_week))).to eq data
          end
        end

        describe 'moment' do
          before :each do
            @params[:group] = 'moment'
          end

          it 'gets the right data' do
            data = [{"value"=>"1.00000000000000000000",
             "label"=>"user4: metric1",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user4: metric2",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user4: metric3",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user4: metric4",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user4: metric5",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric1",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user5: metric2",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user5: metric3",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user5: metric4",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric5",
             "created_at"=>Time.parse(@start_of_week.ago(7.days).to_date.ago(58.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user4: metric1",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user4: metric2",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user4: metric3",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user4: metric4",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user4: metric5",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric1",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"2.0000000000000000",
             "label"=>"user5: metric2",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"3.0000000000000000",
             "label"=>"user5: metric3",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"4.0000000000000000",
             "label"=>"user5: metric4",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone},
            {"value"=>"1.00000000000000000000",
             "label"=>"user5: metric5",
             "created_at"=>Time.parse(@start_of_week.ago(0.days).to_date.ago(59.seconds).to_s).in_time_zone}]

            expect(chart_data_to_hash(AnswerSet.order(:created_at, :label).for_chart(@params), %w(value label created_at))).to eq data
          end
        end
      end
    end

  end

  def chart_data_to_hash(data, keys=nil)
      keys ||= data.first.attributes.keys
      data.map do |datum|
        Hash[keys.map{|key| [key, datum[key]]}]
      end.sort_by {|e| e['created_at']}
    end

  end


  def setup_dummy_data
    @start_of_week = Time.zone.now.beginning_of_week

    @metrics = 5.times.map { |i| FactoryGirl.create(:metric, measure: "metric#{i+1}") }

    @campus1 = FactoryGirl.create(:campus, name: :campus1)
    @campus2 = FactoryGirl.create(:campus, name: :campus2)

    @cohort1 = FactoryGirl.create(:cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort1)
    @cohort2 = FactoryGirl.create(:past_cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort2)
    @cohort3 = FactoryGirl.create(:cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort3)
    @cohort4 = FactoryGirl.create(:past_cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort4)

    @admin_user = FactoryGirl.create(:admin_user)

    @campus_admin = FactoryGirl.create(:user, cohort: nil)
    @campus_admin.administered_campuses << @campus1

    @user1 = FactoryGirl.create(:user, cohort: @cohort1, name: :user1, email: 'user1@test.com')
    @user2 = FactoryGirl.create(:user, cohort: @cohort2, name: :user2, email: 'user2@test.com')
    @user3 = FactoryGirl.create(:user, cohort: @cohort3, name: :user3, email: 'user3@test.com')
    @user4 = FactoryGirl.create(:user, cohort: @cohort1, name: :user4, email: 'user4@test.com')
    @user5 = FactoryGirl.create(:user, cohort: @cohort4, name: :user5, email: 'user5@test.com')

    @cohort_admin = FactoryGirl.create(:user, cohort: nil)
    @cohort_admin.administered_cohorts << @cohort1
    @cohort_admin.administered_cohorts << @cohort3
    @user4.administered_cohorts << @cohort3

    @answer_sets = []
    second_count = 60

    @date1, @date2, @date3, @date4 = [0,7,14,21]
    [@date1, @date2, @date3, @date4].each_with_index do |day, i|
      second_count -= 1

      [@user1, @user2, @user3, @user4, @user5].each do |user|
        answer_set = FactoryGirl.build(:answer_set, user: user, cohort: user.cohort)
        @metrics.each_with_index do |m, j|
          value = [1,2,3,4][j%4]
          answer_set.answers << (answer = FactoryGirl.create(:answer_with_comments, answer_set: answer_set, metric: m, value: value))
          answer.update_attribute(:created_at, @start_of_week.ago(day.days).to_date.ago(second_count.seconds))
        end
        answer_set.update_attribute(:created_at, @start_of_week.ago(day.days).to_date.ago(second_count.seconds))

        @answer_sets << answer_set
      end
    end
  end

end


