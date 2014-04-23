class CreateCampusAdministrators < ActiveRecord::Migration
  def change
    create_table :campus_administrators do |t|
      t.references :administrator
      t.references :campus

      t.timestamps
    end
    add_index :campus_administrators, :administrator_id
    add_index :campus_administrators, :campus_id
  end
end
