class CreateJoinTableCategoriesProducts < ActiveRecord::Migration[7.2]
  def change
    create_join_table :categories, :products do |t|
      t.index :category_id
      t.index :product_id
      t.index [ :category_id, :product_id ], unique: true
    end
  end
end
