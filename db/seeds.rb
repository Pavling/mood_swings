u = User.new(email: 'demo_admin@example.com', password: 'password', password_confirmation: 'password')
u.role = :admin
u.save!
