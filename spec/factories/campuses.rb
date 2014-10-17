FactoryGirl.define do
  factory :campus do
    name { Faker::Address.city }

    factory :campus_with_cohorts do
      after(:create) do |campus, evaluator|
        create(:cohort, campus: campus)
      end

    end
  end
end
