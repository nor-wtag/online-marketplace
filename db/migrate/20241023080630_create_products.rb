class CreateProducts < ActiveRecord::Migration[7.2]
  def up
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.integer :stock
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :title
    add_index :products, :price
  end

  def down
    remove_index :products, :title
    remove_index :products, :price
    drop_table :products
  end
end
