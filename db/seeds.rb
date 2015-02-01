u = User.new(email: 'demo_admin@example.com', name: 'demo admin', password: 'password', password_confirmation: 'password')
u.role = :admin
u.save!

u = User.new(email: 'demo_user@example.com', name: 'demo user', password: 'password', cohort_id: 1, password_confirmation: 'password')
u.save!

Metric.create! measure: "The instructional team is organised and prepared", active: true
Metric.create! measure: "The pace of the class is just right", active: true
Metric.create! measure: "I am enjoying this lesson", active: true
Metric.create! measure: "I think the other students are enjoying this class", active: true
Metric.create! measure: "My general mood is good", active: true

Campus.create! name: 'London'
