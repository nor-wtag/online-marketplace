class CreateUsers < ActiveRecord::Migration[7.2]
  def up
    create_table :users do |t|
      t.string :username
      t.string :email, null: false, default: ""
      t.integer :role
      t.string :phone
      t.string :encrypted_password, null: false, default: ""

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      # Optional Devise fields (Confirmable, Lockable)
      # Uncomment if using these Devise modules
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email
      # t.integer  :failed_attempts, default: 0, null: false
      # t.string   :unlock_token
      # t.datetime :locked_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token, unique: true
    # add_index :users, :unlock_token, unique: true
  end

  def down
    remove_index :users, :email
    remove_index :users, :username
    remove_index :users, :reset_password_token
    # remove_index :users, column: :confirmation_token if index_exists?(:users, :confirmation_token)
    # remove_index :users, column: :unlock_token if index_exists?(:users, :unlock_token)

    drop_table :users
  end
end
