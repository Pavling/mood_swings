class CreateCohortAdministrators < ActiveRecord::Migration
  def change
    create_table :cohort_administrators do |t|
      t.references :administrator
      t.references :cohort

      t.timestamps
    end
    add_index :cohort_administrators, :administrator_id
    add_index :cohort_administrators, :cohort_id
  end
end
