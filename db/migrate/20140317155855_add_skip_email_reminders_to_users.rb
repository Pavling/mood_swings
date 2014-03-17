class AddSkipEmailRemindersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :skip_email_reminders, :boolean, default: false
  end
end
