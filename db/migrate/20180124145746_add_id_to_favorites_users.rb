class AddIdToFavoritesUsers < ActiveRecord::Migration[5.1]
  def change
    drop_table :favoritecontents
    create_table :favoritecontents do |t|
      t.integer :favorite_id, index: true
      t.integer :user_id, index: true
      t.references :content, polymorphic: true, index: true
    end
  end
end
