class CreateEventFilters < ActiveRecord::Migration
  def change
    create_table :event_filters do |t|
      t.integer :event_id
      t.string :action

      t.timestamps
    end
  end
end
