class AddRoleToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :role, :integer, default: User.roles[:user]
  end
end
