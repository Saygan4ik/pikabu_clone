class AddRatingToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :rating, :integer, default: 0.0
    add_index :users, :rating
  end
end
