FactoryGirl.define do
  factory :answer_set do
    association :cohort, factory: :cohort, strategy: :create
    association :user, factory: :user, strategy: :create
  end
end