class AddCampusIdToCohorts < ActiveRecord::Migration
  def change
    add_column :cohorts, :campus_id, :integer
  end
end
