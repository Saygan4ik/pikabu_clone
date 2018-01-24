class ChangeParentAndPostToComments < ActiveRecord::Migration[5.1]
  def change
    remove_index :comments, :post_id
    remove_index :comments, :parent_id
    remove_column :comments, :post_id
    remove_column :comments, :parent_id
    add_column :comments, :commentable_id, :integer
    add_column :comments, :commentable_type, :string
    add_index :comments, [:commentable_id, :commentable_type]
  end
end
