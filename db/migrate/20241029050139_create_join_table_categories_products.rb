class CreateJoinTableCategoriesProducts < ActiveRecord::Migration[7.2]
  def up
    create_join_table :categories, :products do |t|
      t.index :category_id
      t.index :product_id
      t.index [ :category_id, :product_id ], unique: true
    end
  end

  def down
    drop_table :categories_products
  end
end
