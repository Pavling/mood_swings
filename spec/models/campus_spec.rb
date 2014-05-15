require 'spec_helper'

describe Campus do
  it "has a valid factory" do
    expect(FactoryGirl.build(:campus)).to be_valid
  end

  it "is invalid without a name" do
    expect(FactoryGirl.build(:campus, name: nil)).to_not be_valid
  end

  it "must have a unique name" do
    campus = FactoryGirl.create(:campus)
    expect(FactoryGirl.build(:campus, name: campus.name)).to_not be_valid
  end

  it "can destroy if there are no cohorts" do
    campus = FactoryGirl.create(:campus)    
    expect(campus.destroy).to be campus
  end

  it "cannot destroy if there are cohorts" do
    campus = FactoryGirl.create(:campus_with_cohorts)
    expect(campus.destroy).to be false
  end

end