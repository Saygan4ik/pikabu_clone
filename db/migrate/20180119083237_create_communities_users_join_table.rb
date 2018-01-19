class CreateCommunitiesUsersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :communities_users, id: false do |t|
      t.integer :community_id, index: true
      t.integer :user_id, index: true
    end
  end
end
