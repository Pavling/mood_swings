class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :measure
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
