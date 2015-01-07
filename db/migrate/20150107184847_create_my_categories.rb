class CreateMyCategories < ActiveRecord::Migration
  def change
    create_table :my_categories do |t|
      t.integer :category_id

      t.timestamps
    end
  end
end
