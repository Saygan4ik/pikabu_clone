class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :nickname, null: false, unique: true
      t.string :email, null: false, unique: true, index: true
      t.string :password_digest, null: false
      t.string :token, index: true
      t.timestamps
    end
  end
end
