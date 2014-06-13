FactoryGirl.define do
  factory :answer_set do
    association :cohort, factory: :cohort
    association :user, factory: :user

    trait :with_answers do
      after :build do |answer_set|
        3.times { answer_set.answers << FactoryGirl.build(:answer, answer_set: answer_set) }
      end
    end

  end
end