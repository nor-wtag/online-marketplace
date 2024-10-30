class CreateOrders < ActiveRecord::Migration[7.2]
  def up
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_price
      t.string :status
      t.string :verification_code

      t.timestamps
    end
  end

  def down
    drop_table :orders
  end
end
