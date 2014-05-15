FactoryGirl.define do
  factory :user do |f|
    fake_name = Faker::Name.name
    name fake_name
    email { Faker::Internet.email(fake_name) }
    password 'password'
    password_confirmation 'password'
  end
end