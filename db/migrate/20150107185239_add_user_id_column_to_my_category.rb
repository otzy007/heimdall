class AddUserIdColumnToMyCategory < ActiveRecord::Migration
  def change
    add_column :my_categories, :user_id, :integer
  end
end
