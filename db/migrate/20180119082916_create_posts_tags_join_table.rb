class CreatePostsTagsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :posts_tags, id: false do |t|
      t.integer :post_id, index: true
      t.integer :tag_id, index: true
    end
  end
end
