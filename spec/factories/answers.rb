FactoryGirl.define do
  factory :answer do |f|
    f.value { (1..5).to_a.sample }
    f.comments { Faker::Lorem.sentence }
    association :metric, factory: :metric, strategy: :create
  end
end