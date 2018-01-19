class CreateFavoritesUsersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :favorites_users, id: false do |t|
      t.integer :favorite_id, index: true
      t.integer :user_id, index: true
      t.references :content, polymorphic: true, index: true
    end
  end
end
