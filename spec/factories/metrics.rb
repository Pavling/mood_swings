FactoryGirl.define do
  factory :metric do
    active true
    measure { Faker::Lorem.sentence }
    
    factory :metric_with_answers do
      after(:create) do |metric, evaluator|
        create(:answer, metric: metric)
      end

    end
  end
end