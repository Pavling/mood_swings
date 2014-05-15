FactoryGirl.define do
  factory :cohort do
    name { Faker::Team.name }
    start_on { (3.months.ago.to_date..Date.yesterday).to_a.sample }
    end_on { (Date.tomorrow..3.months.since.to_date).to_a.sample }
  end
end