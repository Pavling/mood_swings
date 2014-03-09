class UserMailer < ActionMailer::Base
  default from: "ga.moodswings@gmail.com"

  def reminder(user)
    @user = user
    mail(to: user.email, subject: "Swing Your Mood")
  end

end
