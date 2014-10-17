class CreateCampus < ActiveRecord::Migration
  def change
    create_table :campuses do |t|
      t.string :name, unique: true

      t.timestamps
    end
  end
end
