class CreateOrderItems < ActiveRecord::Migration[7.2]
  def up
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end
  end

  def down
    drop_table :order_items
  end
end
