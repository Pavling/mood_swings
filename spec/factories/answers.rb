FactoryGirl.define do
  factory :answer do
    value { (1..5).to_a.sample }
    association :metric, factory: :metric

    factory :answer_with_comments do
      comments { Faker::Lorem.sentence }
    end
  end
end