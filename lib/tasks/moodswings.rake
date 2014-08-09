namespace :moodswings do
  desc "Send reminder emails to all users that have not logged their mood recently"
  task :send_reminder_emails => :environment do
    User.needing_reminder_email.configured_to_receive_email_reminders.each do |user|
      begin
        user.send_reminder_email!
      rescue Exception => e
        Rails.logger.error "ERROR! #{e}"
      end
    end
  end

end
