class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :text
      t.string :image
      t.belongs_to :user, index: true
      t.belongs_to :post, index: true
      t.references :parent, index: true
      t.timestamps
    end
  end
end
