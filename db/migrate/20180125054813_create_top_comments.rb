class CreateTopComments < ActiveRecord::Migration[5.1]
  def change
    create_table :top_comments do |t|
      t.timestamp :date, null: false
      t.belongs_to :comment
      t.integer :rating
    end
  end
end
