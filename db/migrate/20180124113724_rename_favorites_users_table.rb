class RenameFavoritesUsersTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :favorites_users, :favoritecontents
  end
end
