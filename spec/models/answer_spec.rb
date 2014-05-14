require 'spec_helper'

describe Answer do
  it "has a valid factory" do
    expect(FactoryGirl.create(:answer)).to be_valid
  end

  it "is invalid without a value" do
    expect(FactoryGirl.build(:answer, value: nil)).to_not be_valid
  end

  it "is invalid unless value is between 1 and 5" do
    answer = FactoryGirl.build (:answer)
    ((-100..100).to_a - (1..5).to_a).each do |value|
      answer.value = value
      expect(answer).to_not be_valid
    end
  end

  it "is valid with a value between 1 and 5" do
    answer = FactoryGirl.build (:answer)
    (1..5).to_a.each do |value|
      answer.value = value
      expect(answer).to be_valid
    end
  end

  it "is invalid without a metric" do
    expect(FactoryGirl.build(:answer, metric: nil)).to_not be_valid
  end

  it "must have a unique metric within the scope of its AnswerSet" do
    metric = FactoryGirl.create(:metric)
    FactoryGirl.create(:answer, metric: metric)
    expect(FactoryGirl.build(:answer, metric: metric)).to_not be_valid
  end
  
  it "cannot be destroyed" do
    answer = FactoryGirl.create(:answer)
    expect(answer.destroy).to be false
  end
  
  it "removes comments that are placeholders for 'no answer'" do
    non_comments = ['n/a', 'N/A', '  n/A   ']

    non_comments.each do |non_comment|
      answer = FactoryGirl.create(:answer, comments: non_comment)
      expect(answer.comments).to be_nil
    end
  end

  it "leave comments in place they're genuine comments" do
    comments = Faker::Lorem.sentence
    answer = FactoryGirl.create(:answer, comments: comments)
    expect(answer.comments).to eq comments
  end

  it "sets up default values for the knob-data" do
    answer = FactoryGirl.create(:answer)
    default_knob_data = {
      fgColor: "#66CC66",
      angleOffset: -125,
      angleArc: 250,
      width: 75,
      height: 75,
      min: 1,
      max: 5,
      cursor: true,
      linecap: :round,
    }
    expect(answer.knob_data).to eq default_knob_data
  end


end
