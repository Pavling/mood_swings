require 'spec_helper'

describe AnswerSet do
  it "has a valid factory" do
    expect(FactoryGirl.build(:answer_set)).to be_valid
  end

  it "cannot be destroyed" do
    answer_set = FactoryGirl.create(:answer_set)
    expect(answer_set.destroy).to be false
  end
  
  it "is invalid without a cohort" do
    expect(FactoryGirl.build(:answer_set, cohort: nil)).to_not be_valid
  end

  it "is invalid without a user" do
    expect(FactoryGirl.build(:answer_set, user: nil)).to_not be_valid
  end

  it "must not have another by the same user in the last five minutes" do
    user = FactoryGirl.create(:user)
    answer_set = FactoryGirl.create(:answer_set, user: user)
    answer_set.update_attribute(:created_at, 4.minutes.ago)

    expect(FactoryGirl.build(:answer_set, user: user)).to_not be_valid
  end

  it "can have another by the same user after five minutes" do
    user = FactoryGirl.create(:user)
    old_answer_set = FactoryGirl.create(:answer_set, user: user)
    old_answer_set.update_attribute(:created_at, 5.minutes.ago)

    expect(FactoryGirl.build(:answer_set, user: user)).to be_valid
  end

  describe '.with_comments' do
    it 'returns all the answer_sets which have answers with commments' do
      no_comment_answer_set = FactoryGirl.create(:answer_set)
      no_comment_answer_set.answers << FactoryGirl.create(:answer)

      comment_answer_set_1 = FactoryGirl.create(:answer_set)
      comment_answer_set_1.answers << FactoryGirl.create(:answer_with_comments)
      comment_answer_set_1.answers << FactoryGirl.create(:answer)

      comment_answer_set_2 = FactoryGirl.create(:answer_set)
      comment_answer_set_2.answers << FactoryGirl.create(:answer_with_comments)
      comment_answer_set_2.answers << FactoryGirl.create(:answer_with_comments)

      expect(AnswerSet.with_comments.sort).to eq [comment_answer_set_1, comment_answer_set_2].sort
    end
  end

  describe '.last_five_minutes' do
    it 'returns all the answer_sets created in the last five minutes' do
      old_answer_set = FactoryGirl.create(:answer_set)
      old_answer_set.update_attribute(:created_at, 5.minutes.ago)

      answer_set = FactoryGirl.create(:answer_set)

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
      answer_set = FactoryGirl.create(:answer_set, user: @user, cohort: @user.cohort)
      @metrics.each { |m| FactoryGirl.create(:answer_with_comments, answer_set: answer_set, metric: m) }
      answer_set.update_attribute(:created_at, 20.minutes.ago)

      last_answer_set = FactoryGirl.create(:answer_set, user: @user, cohort: @user.cohort)
      @metrics.each { |m| FactoryGirl.create(:answer_with_comments, answer_set: last_answer_set, metric: m) }
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
      @metrics = 5.times.map { FactoryGirl.create(:metric) }

      @campus1 = FactoryGirl.create(:campus)
      @campus2 = FactoryGirl.create(:campus)

      @cohort1 = FactoryGirl.create(:cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort1)
      @cohort2 = FactoryGirl.create(:past_cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort2)
      @cohort3 = FactoryGirl.create(:cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort3)
      @cohort4 = FactoryGirl.create(:past_cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort4)

      @admin_user = FactoryGirl.create(:admin_user)

      @campus_admin = FactoryGirl.create(:user, cohort: nil)
      @campus_admin.administered_campuses << @campus1

      @user1 = FactoryGirl.create(:user, cohort: @cohort1, name: :user1)
      @user2 = FactoryGirl.create(:user, cohort: @cohort2, name: :user2)
      @user3 = FactoryGirl.create(:user, cohort: @cohort3, name: :user3)
      @user4 = FactoryGirl.create(:user, cohort: @cohort1, name: :user4)
      @user5 = FactoryGirl.create(:user, cohort: @cohort4, name: :user5)

      @cohort_admin = FactoryGirl.create(:user, cohort: nil)
      @cohort_admin.administered_cohorts << @cohort1
      @cohort_admin.administered_cohorts << @cohort3
      @user4.administered_cohorts << @cohort3

      @answer_sets = []

      (2..20).to_a.reverse.each do |day|
        user = [@user1, @user2, @user3, @user4, @user5].sample
        answer_set = FactoryGirl.create(:answer_set, user: user, cohort: user.cohort)
        @metrics.each { |m| FactoryGirl.create(:answer_with_comments, answer_set: answer_set, metric: m) }
        answer_set.update_attribute(:created_at, day.days.ago.to_date)
        @answer_sets << answer_set
      end
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

  it '.for_chart'



end














