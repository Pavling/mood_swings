class CreateCohorts < ActiveRecord::Migration
  def change
    create_table :cohorts do |t|
      t.string :name
      t.date :start_on
      t.date :end_on

      t.timestamps
    end

    add_column :answer_sets, :cohort_id, :integer
    add_column :users, :cohort_id, :integer

  end
end
