class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :answer_set
      t.references :metric
      t.string :value
      t.text :comments

      t.timestamps
    end
    add_index :answers, :answer_set_id
    add_index :answers, :metric_id
  end
end
