require 'spec_helper'

describe Metric do
  it "has a valid factory" do
    expect(FactoryGirl.create(:metric)).to be_valid
  end

  it "is invalid without a measure" do
    expect(FactoryGirl.build(:metric, measure: nil)).to_not be_valid
  end
  
  it "is invalid without active being set to `true` or `false`" do
    expect(FactoryGirl.build(:metric, active: nil)).to_not be_valid
  end

  it "accepts `true` or `false` as valid values for active" do
    [true, false].each do |value|
      expect(FactoryGirl.build(:metric, active: value)).to be_valid
    end
  end

  it "cannot change measure on update" do
    metric = FactoryGirl.create(:metric)
    metric.measure = Faker::Lorem.sentence
    expect(metric).to_not be_valid
  end

  it "can destroy if there are no answers" do
    metric = FactoryGirl.create(:metric)    
    expect(metric.destroy).to be metric
  end

  it "cannot destroy if there are answers" do
    metric = FactoryGirl.create(:metric_with_answers)
    expect(metric.destroy).to be false
  end


end