class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :keyword
      t.integer :score
      t.string :parent

      t.timestamps
    end
  end
end
