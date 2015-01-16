class SetDefaultValueForScoreOnKeyword < ActiveRecord::Migration
  def change
    change_column :keywords, :score, :integer, :default => 0
  end
end
