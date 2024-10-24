class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[7.0]
  def up
    change_column :users, :role, :integer, using: 'CASE role WHEN \'admin\' THEN 0 WHEN \'buyer\' THEN 1 WHEN \'seller\' THEN 2 WHEN \'rider\' THEN 3 END'
  end

  def down
    change_column :users, :role, :string
  end
end
