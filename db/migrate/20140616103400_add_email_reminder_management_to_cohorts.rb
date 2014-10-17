class AddEmailReminderManagementToCohorts < ActiveRecord::Migration
  def change
    add_column :cohorts, :skip_email_reminders, :boolean, default: false
    add_column :cohorts, :allow_users_to_manage_email_reminders, :boolean, default: true
  end
end
