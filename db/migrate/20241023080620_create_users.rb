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
  end

  def down
    drop_table :users
  end
end
