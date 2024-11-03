class CreateUsers < ActiveRecord::Migration[7.2]
  def up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.integer :role
      t.string :password, null: false
      t.string :phone

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :role
  end

  def down
    remove_index :users, :email
    remove_index :users, :username
    remove_index :users, :role
    drop_table :users
  end
end
