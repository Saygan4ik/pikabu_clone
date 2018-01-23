class ChangeTypeRatingToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :rating
    remove_column :users, :rating
    add_column :users, :rating, :float, default: 0.0
    add_index :users, :rating
  end
end
