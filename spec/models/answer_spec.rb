require 'spec_helper'

describe Answer do
  it "has a valid factory" do
    expect(FactoryGirl.build(:answer)).to be_valid
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

  it "has an accessor for `not_applicable`" do
    answer = FactoryGirl.create(:answer)
    answer.not_applicable = true
    expect(answer.not_applicable).to be true
  end

  describe "must have a unique metric withing the scope of its AnswerSet" do
    it 'is valid with duplicate metrics across answer_sets' do
      answer = FactoryGirl.create(:answer, answer_set: FactoryGirl.build(:answer_set, :with_answers))
      expect(FactoryGirl.build(:answer, metric: answer.metric, answer_set: FactoryGirl.build(:answer_set, :with_answers))).to be_valid
    end

    it 'is invalid with duplicate metric in the same answer_set' do
      answer = FactoryGirl.create(:answer)
      expect(FactoryGirl.build(:answer, metric: answer.metric, answer_set: answer.answer_set)).to_not be_valid
    end
  end
  
  it "cannot be destroyed" do
    answer = FactoryGirl.create(:answer)
    expect(answer.destroy).to be false
  end
  
  describe '#comments' do
    it "removes comments that are placeholders for 'no answer'" do
      non_comments = ['n/a', 'N/A', '  n/A   ']

      non_comments.each do |non_comment|
        answer = FactoryGirl.create(:answer, comments: non_comment)
        expect(answer.comments).to be_nil
      end
    end

    it "leave comments in place if they're genuine comments" do
      comments = Faker::Lorem.sentence
      answer = FactoryGirl.create(:answer, comments: comments)
      expect(answer.comments).to eq comments
    end
  end

  describe '#knob_data' do
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

end
