FactoryGirl.define do
  factory :answer do |f|
    f.value { (1..5).to_a.sample }
    association :metric, factory: :metric, strategy: :build
  end
end