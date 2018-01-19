class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :text
      t.belongs_to :user, index: true
      t.belongs_to :community, index: true
      t.json :files
      t.boolean :isHot, default: false
      t.timestamps
    end
  end
end
