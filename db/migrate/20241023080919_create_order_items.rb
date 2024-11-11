class CreateOrderItems < ActiveRecord::Migration[7.2]
  def up
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity
      t.decimal :price
      t.string :status, default: 'pending'
      t.string :availibility, default: 'available'
      t.references :rider, foreign_key: { to_table: :users }
      t.timestamps
    end
  end

  def down
    drop_table :order_items
  end
end
