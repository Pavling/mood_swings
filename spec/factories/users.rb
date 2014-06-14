FactoryGirl.define do
  factory :user do |f|
    fake_name = Faker::Name.name
    name fake_name
    email { Faker::Internet.email(fake_name) }
    password 'password'
    password_confirmation 'password'

    factory :user_with_answer_sets do
      cohort FactoryGirl.build(:cohort)

      after(:create) do |user, evaluator|
        user.answer_sets << create(:answer_set, :with_answers, user: user, cohort: user.cohort)
      end
    end

    factory :admin_user do
      role 'admin'
    end

    factory :cohort_admin_user do
      after(:create) do |user, evaluator|
        create(:cohort_administrator, administrator: user, cohort: create(:cohort))
      end
    end

    factory :campus_admin_user do
      after(:create) do |user, evaluator|
        create(:campus_administrator, administrator: user, campus: create(:campus))
      end
    end

  end
end