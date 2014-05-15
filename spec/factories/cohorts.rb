FactoryGirl.define do
  factory :cohort do
    name { Faker::Team.name }
    start_on { (3.months.ago.to_date..Date.today.yesterday).to_a.sample }
    end_on { (Date.today.tomorrow..3.months.since.to_date).to_a.sample }

    factory :future_cohort do
      start_on Date.today.tomorrow
    end

    factory :past_cohort do
      end_on Date.today.yesterday
    end

    factory :cohort_with_answer_sets do
      after(:create) do |cohort, evaluator|
        create(:answer_set, cohort: cohort)
      end
    end

  end
end