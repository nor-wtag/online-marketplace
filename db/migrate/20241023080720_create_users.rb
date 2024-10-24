class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :role
      t.string :password_digest
      t.integer :phone

      t.timestamps
    end
  end
end
