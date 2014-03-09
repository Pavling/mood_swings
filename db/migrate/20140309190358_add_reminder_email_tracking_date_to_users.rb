class AddReminderEmailTrackingDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reminder_email_sent_at, :datetime
  end
end
