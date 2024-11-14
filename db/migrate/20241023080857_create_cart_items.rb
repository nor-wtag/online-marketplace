class CreateCartItems < ActiveRecord::Migration[7.2]
  def up
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end

  def down
    drop_table :cart_items
  end
end
