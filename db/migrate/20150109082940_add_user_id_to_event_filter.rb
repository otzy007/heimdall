class AddUserIdToEventFilter < ActiveRecord::Migration
  def change
    add_column :event_filters, :user_id, :integer
  end
end
