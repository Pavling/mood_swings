class CreateAnswerSets < ActiveRecord::Migration
  def change
    create_table :answer_sets do |t|
      t.references :user

      t.timestamps
    end
    add_index :answer_sets, :user_id
  end
end
