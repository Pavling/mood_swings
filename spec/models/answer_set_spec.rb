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


  it '.from_last_set_for'

  it '.for_index'

  it '.for_chart'



end














