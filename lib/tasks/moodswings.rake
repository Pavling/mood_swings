namespace :moodswings do
  desc "Send reminder emails to all users that have not logged their mood recently"
  task :send_reminder_emails => :environment do
    User.needing_reminder_email.configured_to_receive_email_reminders.each do |user|
      if user.reminder_email_sent_at.nil? || user.reminder_email_sent_at < Time.now - 20.hours
        begin
          Rails.logger.info "REMINDER EMAIL: emailing #{user.email}"
          UserMailer.reminder(user).deliver
          user.update_attribute :reminder_email_sent_at, Time.now
        rescue Exception => e
          Rails.logger.error "ERROR! #{e}"
        end
      end
    end
  end

end
