class CreateFavorites < ActiveRecord::Migration[5.1]
  def change
    create_table :favorites do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end
  end
end
