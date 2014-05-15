require 'spec_helper'

describe Cohort do
  it "has a valid factory" do
    expect(FactoryGirl.build(:cohort)).to be_valid
  end

  it "is invalid without a name" do
    expect(FactoryGirl.build(:cohort, name: nil)).to_not be_valid
  end

  it "must have a unique name" do
    cohort = FactoryGirl.create(:cohort)
    expect(FactoryGirl.build(:cohort, name: cohort.name)).to_not be_valid
  end

  it "is invalid without a start_on date" do
    expect(FactoryGirl.build(:cohort, start_on: nil)).to_not be_valid
  end

  it "is invalid without an end_on date" do
    expect(FactoryGirl.build(:cohort, end_on: nil)).to_not be_valid
  end

  it "must end after it starts" do
    expect(FactoryGirl.build(:cohort, start_on: Date.today.tomorrow, end_on: Date.today)).to_not be_valid
  end

  it "can destroy if there are no answer_sets" do
    cohort = FactoryGirl.create(:cohort)    
    expect(cohort.destroy).to be cohort
  end

  it "cannot destroy if there are answer_sets" do
    cohort = FactoryGirl.create(:cohort_with_answer_sets)
    expect(cohort.destroy).to be false
  end

  it 'is ordered by name by default' do
    cohort1 = FactoryGirl.create(:cohort, name: 'b')
    cohort2 = FactoryGirl.create(:cohort, name: 'c')
    cohort3 = FactoryGirl.create(:cohort, name: 'a')
    expect(Cohort.all).to eq [cohort3, cohort1, cohort2]
  end

  describe 'scopes for currently_running and future' do
    before :each do 
      @current_cohort = FactoryGirl.create(:cohort)
      @future_cohort = FactoryGirl.create(:future_cohort)
      @past_cohort = FactoryGirl.create(:past_cohort)      
    end

    describe '.currently_running' do
      it 'returns cohorts that the start_on is before (or equal) today and the end_on is after (or equal) today' do
        expect(Cohort.currently_running.map(&:id)).to eql [@current_cohort.id]
      end
    end

    describe '.future' do
      it 'returns cohorts that the start_on is greater than today' do
        expect(Cohort.future.map(&:id)).to eql [@future_cohort.id]
      end
    end

    describe '.current_and_future' do
      it 'returns all cohorts ending in the future' do
        ids = [@current_cohort, @future_cohort].map(&:id).sort
        expect(Cohort.current_and_future.map(&:id).sort).to eql ids
      end
    end
  end

  describe '#currently_running?' do
    describe 'for running cohorts' do
      it 'should be running' do
        expect(FactoryGirl.create(:cohort).currently_running?).to be_true
      end
    end

    describe 'for future cohorts' do
      it 'should not be running' do
        expect(FactoryGirl.create(:future_cohort).currently_running?).to be_false
      end
    end

    describe 'for past cohorts' do
      it 'should not be running' do
        expect(FactoryGirl.create(:past_cohort).currently_running?).to be_false
      end
    end
  end

end